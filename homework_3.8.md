## Домашняя работа к занятию "3.8. Компьютерные сети, лекция 3"

---

1. __ipvs. Если при запросе на VIP сделать подряд несколько запросов (например, for i in {1..50}; do curl -I -s 172.28.128.200>/dev/null; done ), ответы будут получены почти мгновенно. Тем не менее, в выводе ipvsadm -Ln еще некоторое время будут висеть активные InActConn. Почему так происходит?__

В режиме LVS-NAT директор пропускает через себя всю информацию, что позволяет видеть, когда соединение открыто и закрыто.
В режиме же DR (Direct routing) идет перенаправление пакета на VIP адрес реала, но реал обратно отвечает напрямую клиенту, минуя балансер.
Отсюда следует, что директор не знатает, когда будет закрыто TCP-соединение, так как иницатива на закрытие TCP-соединения (FIN) будет со стороны реала и пройдёти "мимо".
Но директор увидет только ответ от клиента - ACK на закрытие соединение FIN. Соответственно, он лишь предполагает, что соединение закрыто и прибавляет его в InActConn до истечения таймаута (по умолчанию команда ipvsadm -l --timeout Timeout (tcp tcpfin udp): 900 120 300)

---

2. __На лекции мы познакомились отдельно с ipvs и отдельно с keepalived. Воспользовавшись этими знаниями, совместите технологии вместе (VIP должен подниматься демоном keepalived).
Приложите конфигурационные файлы, которые у вас получились, и продемонстрируйте работу получившейся конструкции. Используйте для директора отдельный хост, не совмещая его с риалом!
Подобная схема возможна, но выходит за рамки рассмотренного на лекции.__

# Реализована схема из 5 виртуальных машин. Использовался следующий vagrant file для быстрой развертки:
	
	# -*- mode: ruby -*-
	# vi: set ft=ruby :

	boxes = {
	  'netology1' => '10',
	  'netology2' => '20',
	  'netology3' => '30',
	  'netology4' => '40',
	  'netology5' => '50',
	}

	Vagrant.configure("2") do |config|
	  config.vm.network "private_network", virtualbox__intnet: true, auto_config: false
	  config.vm.box = "bento/ubuntu-20.04"

	  boxes.each do |k, v|
		config.vm.define k do |node|
		  node.vm.provision "shell" do |s|
			s.inline = "hostname $1;"\
			  "ip addr add $2 dev eth1;"\
			  "ip link set dev eth1 up;"\
			  "apt -y install nginx;"\
			  "apt -y install ipvsadm;"
			s.args = [k, "172.28.128.#{v}/24"]
		  end
		end
	  end

	end
---
	netology1  - real server nginx №1 172.28.128.10
	netology2  - real server nginx №2 172.28.128.20
	netology3  - хост - клиент 172.28.128.30
	netology4  - balancer №1 172.28.128.30  (VIP 172.28.128.200:80)
	netology5  - balancer №2 172.28.128.40  (VIP 172.28.128.200:80)
---
# Конфигурация балансера №1:

	 vrrp_script chk_nginx {
	    script "systemctl status nginx"
	    interval 2
	}

	vrrp_instance VI_1 {
	    state BACKUP
	    interface eth1
	    virtual_router_id 33
	    priority 90
	    advert_int 1
	    authentication {
		auth_type PASS
		auth_pass netology
	    }
	    virtual_ipaddress {
		172.28.128.200/32 dev eth1
	    }
	    track_script  {
		chk_nginx
	    }
	}

	virtual_server 172.28.128.200 80 {
	    delay_loop 6
	    lb_algo rr
	    lb_kind DR
	    protocol TCP
	    real_server 172.28.128.10 80 {
		   weight 1
		   TCP_CHECK {
		      connect_timeout 2
		   }
		}
	     real_server 172.28.128.20 80 {
		   weight 1
		   TCP_CHECK {
		      connect_timeout 2
		   }
		}
	}
---
# Конфигурация балансера №2:
	
	vrrp_script chk_nginx {
	    script "systemctl status nginx"
	    interval 2
	}

	vrrp_instance VI_1 {
	    state MASTER
	    interface eth1
	    virtual_router_id 33
	    priority 100
	    advert_int 1
	    authentication {
		auth_type PASS
		auth_pass netology
	    }
	    virtual_ipaddress {
		172.28.128.200/32 dev eth1
	    }
	    track_script  {
		chk_nginx
	    }
	}

	virtual_server 172.28.128.200 80 {
		delay_loop 6
		lb_algo rr
		lb_kind DR
		protocol TCP
		real_server 172.28.128.10 80 {
		   weight 1
		   TCP_CHECK {
		      connect_timeout 2
		   }
		}
		real_server 172.28.128.20 80 {
		   weight 1
		   TCP_CHECK {
		      connect_timeout 2
		   }
		}
	}
---
# Службы keepalived запущены на обоих балансерах:
Балансер №1
	
	keepalived.service - Keepalive Daemon (LVS and VRRP)
	     Loaded: loaded (/lib/systemd/system/keepalived.service; enabled; vendor preset: enabled)
	     Active: active (running) since Thu 2021-05-06 17:36:15 UTC; 7min ago
	   Main PID: 726 (keepalived)
	      Tasks: 3 (limit: 1113)
	     Memory: 6.2M
	     CGroup: /system.slice/keepalived.service
		     ├─726 /usr/sbin/keepalived --dont-fork
		     ├─733 /usr/sbin/keepalived --dont-fork
		     └─734 /usr/sbin/keepalived --dont-fork

	May 06 17:38:25 netology4 Keepalived_vrrp[734]: Netlink reports eth1 up
	May 06 17:38:25 netology4 Keepalived_vrrp[734]: (VI_1) Entering BACKUP STATE
	May 06 17:38:25 netology4 Keepalived_healthcheckers[733]: TCP connection to [172.28.128.10]:tcp:80 success.
	May 06 17:38:25 netology4 Keepalived_healthcheckers[733]: Adding service [172.28.128.10]:tcp:80 to VS [172.28.128.200]:tcp:80
	May 06 17:38:25 netology4 Keepalived_healthcheckers[733]: Gained quorum 1+0=1 <= 1 for VS [172.28.128.200]:tcp:80
	May 06 17:38:27 netology4 Keepalived_healthcheckers[733]: TCP connection to [172.28.128.20]:tcp:80 success.
	May 06 17:38:27 netology4 Keepalived_healthcheckers[733]: Adding service [172.28.128.20]:tcp:80 to VS [172.28.128.200]:tcp:80
	May 06 17:38:29 netology4 Keepalived_vrrp[734]: (VI_1) Entering MASTER STATE
	May 06 17:38:30 netology4 Keepalived_vrrp[734]: (VI_1) Master received advert from 172.28.128.50 with higher priority 100, ours 90
	May 06 17:38:30 netology4 Keepalived_vrrp[734]: (VI_1) Entering BACKUP STATE

Балансер №2
	
	keepalived.service - Keepalive Daemon (LVS and VRRP)
	     Loaded: loaded (/lib/systemd/system/keepalived.service; enabled; vendor preset: enabled)
	     Active: active (running) since Thu 2021-05-06 17:36:36 UTC; 8min ago
	   Main PID: 675 (keepalived)
	      Tasks: 3 (limit: 1113)
	     Memory: 6.2M
	     CGroup: /system.slice/keepalived.service
		     ├─675 /usr/sbin/keepalived --dont-fork
		     ├─681 /usr/sbin/keepalived --dont-fork
		     └─682 /usr/sbin/keepalived --dont-fork

	May 06 17:38:26 netology5 Keepalived_vrrp[682]: Netlink reports eth1 up
	May 06 17:38:26 netology5 Keepalived_vrrp[682]: (VI_1) Entering BACKUP STATE
	May 06 17:38:27 netology5 Keepalived_healthcheckers[681]: TCP connection to [172.28.128.10]:tcp:80 success.
	May 06 17:38:27 netology5 Keepalived_healthcheckers[681]: Adding service [172.28.128.10]:tcp:80 to VS [172.28.128.200]:tcp:80
	May 06 17:38:27 netology5 Keepalived_healthcheckers[681]: Gained quorum 1+0=1 <= 1 for VS [172.28.128.200]:tcp:80
	May 06 17:38:28 netology5 Keepalived_healthcheckers[681]: TCP connection to [172.28.128.20]:tcp:80 success.
	May 06 17:38:28 netology5 Keepalived_healthcheckers[681]: Adding service [172.28.128.20]:tcp:80 to VS [172.28.128.200]:tcp:80
	May 06 17:38:28 netology5 Keepalived_vrrp[682]: (VI_1) received lower priority (90) advert from 172.28.128.40 - discarding
	May 06 17:38:29 netology5 Keepalived_vrrp[682]: (VI_1) received lower priority (90) advert from 172.28.128.40 - discarding
	May 06 17:38:30 netology5 Keepalived_vrrp[682]: (VI_1) Entering MASTER STATE
---
# Запуск curl на хосте-клиенте:

	root@netology3:/home/vagrant# for i in {1..50}; do curl -I -s 172.28.128.200>/dev/null; done

Обращение на real server 1
	
	root@netology2:/home/vagrant# wc -l /var/log/nginx/access.log
	1 /var/log/nginx/access.log
	root@netology2:/home/vagrant# wc -l /var/log/nginx/access.log
	26 /var/log/nginx/access.log

Обращение на real server 2
	
	root@netology1:/home/vagrant# wc -l /var/log/nginx/access.log
	1 /var/log/nginx/access.log
	root@netology1:/home/vagrant# wc -l /var/log/nginx/access.log
	26 /var/log/nginx/access.log

Результат ipvsadm -Ln на балансере №2 Maser:
	
	root@netology5:/home/vagrant# ipvsadm -Ln
	IP Virtual Server version 1.2.1 (size=4096)
	Prot LocalAddress:Port Scheduler Flags
	  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
	TCP  172.28.128.200:80 rr
	  -> 172.28.128.10:80             Route   1      0          50
	  -> 172.28.128.20:80             Route   1      0          50
---
# Отклюючим службу keepalived на балансере №2
	
	systemctl stop keepalived
	Балансер №1 стал Master:
	keepalived.service - Keepalive Daemon (LVS and VRRP)
	     Loaded: loaded (/lib/systemd/system/keepalived.service; enabled; vendor preset: enabled)
	     Active: active (running) since Thu 2021-05-06 17:49:10 UTC; 7min ago
	   Main PID: 1692 (keepalived)
	      Tasks: 3 (limit: 1113)
	     Memory: 2.1M
	     CGroup: /system.slice/keepalived.service
		     ├─1692 /usr/sbin/keepalived --dont-fork
		     ├─1703 /usr/sbin/keepalived --dont-fork
		     └─1704 /usr/sbin/keepalived --dont-fork

	May 06 17:49:10 netology4 Keepalived_vrrp[1704]: WARNING - default user 'keepalived_script' for script execution>
	May 06 17:49:10 netology4 Keepalived_vrrp[1704]: WARNING - script `systemctl` resolved by path search to `/usr/b>
	May 06 17:49:10 netology4 Keepalived_vrrp[1704]: SECURITY VIOLATION - scripts are being executed but script_secu>
	May 06 17:49:10 netology4 Keepalived_vrrp[1704]: Registering gratuitous ARP shared channel
	May 06 17:49:10 netology4 Keepalived_vrrp[1704]: VRRP_Script(chk_nginx) succeeded
	May 06 17:49:10 netology4 Keepalived_vrrp[1704]: (VI_1) Entering BACKUP STATE
	May 06 17:49:11 netology4 Keepalived_healthcheckers[1703]: TCP connection to [172.28.128.20]:tcp:80 success.
	May 06 17:49:13 netology4 Keepalived_healthcheckers[1703]: TCP connection to [172.28.128.10]:tcp:80 success.
	May 06 17:56:12 netology4 Keepalived_vrrp[1704]: (VI_1) Backup received priority 0 advertisement
	May 06 17:56:13 netology4 Keepalived_vrrp[1704]: (VI_1) Entering MASTER STATE

Проверим балансировку с хост-клиента:
	
	root@netology4:/home/vagrant# ipvsadm -Ln
	IP Virtual Server version 1.2.1 (size=4096)
	Prot LocalAddress:Port Scheduler Flags
	  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
	TCP  172.28.128.200:80 rr
	  -> 172.28.128.10:80             Route   1      0          25
	  -> 172.28.128.20:80             Route   1      0          25

Балансировка работает.
---
3. __В лекции мы использовали только 1 VIP адрес для балансировки.
У такого подхода несколько отрицательных моментов, один из которых – невозможность активного использования нескольких хостов (1 адрес может только переехать с master на standby).
Подумайте, сколько адресов оптимально использовать, если мы хотим без какой-либо деградации выдерживать потерю 1 из 3 хостов при входящем трафике 1.5 Гбит/с и физических линках хостов в 1 Гбит/с?
Предполагается, что мы хотим задействовать 3 балансировщика в активном режиме (то есть не 2 адреса на 3 хоста, один из которых в обычное время простаивает).__

Если взять 3 адреса, то входящая нагрузка в 1.5 Гбит/с поделится между каждым хостом, примерно по 500 Мбит/с на хост. Когда "упадет" один из хостов, мы получим, что эти 500 Мб/с перейдут на один из 2-х оставшихся хостов
Получится, что 1 Гбит/с будет на одном хосте - что утилизирует весь канал равным 1 Гбит/с. А это приведет к потерям. Отсюда следует, что 3 адреса нам не подходит.

Если взять 4 адреса, то примерная назгрузка на каждый канал составит 375 Мбит/c. Если хост "падает", то на один из 2-х оставшихся хостов попадет 2*375 Мбит/c =750 Мбит/c, а на другом только 375 Мбит/c. Получается, что мы не сможем использовать полноценно один из хостов.

Если взять 5 адресов, то примерная назгрузка на каждый канал составит 300 Мбит/c. Если хост "падает", то на оба хоста попадает по 600 Мбит/c одинково. Что считаю оптимальным.
