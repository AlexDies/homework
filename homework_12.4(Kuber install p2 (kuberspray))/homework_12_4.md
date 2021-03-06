# Домашнее задание к занятию "12.4 Развертывание кластера на собственных серверах, лекция 2"
Новые проекты пошли стабильным потоком. Каждый проект требует себе несколько кластеров: под тесты и продуктив. Делать все руками — не вариант, поэтому стоит автоматизировать подготовку новых кластеров.

## Задание 1: Подготовить инвентарь kubespray
Новые тестовые кластеры требуют типичных простых настроек. Нужно подготовить инвентарь и проверить его работу. Требования к инвентарю:
* подготовка работы кластера из 5 нод: 1 мастер и 4 рабочие ноды;
* в качестве CRI — containerd;
* запуск etcd производить на мастере.

## Задание 2 (*): подготовить и проверить инвентарь для кластера в AWS
Часть новых проектов хотят запускать на мощностях AWS. Требования похожи:
* разворачивать 5 нод: 1 мастер и 4 рабочие ноды;
* работать должны на минимально допустимых EC2 — t3.small.

___
## Выполнение ДЗ:
## Задание 1: Подготовить инвентарь kubespray

##### 1. Подготовим VM в Yandex Cloud:

Необходима `1 Control Node(cp1)` и `4 Worker Node (node1,node2,node3,node4)`

Подредактируем скрипт для работы с YC CLI на создание VM:

        #!/bin/bash

        set -e

        function create_vm {
        local NAME=$1

        YC=$(cat <<END
            yc compute instance create \
            --name $NAME \
            --zone ru-central1-a \
            --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
            --preemptible \
            --memory 2 \
            --cores 2 \
            --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-2004-lts,type=network-ssd,size=20 \
            --ssh-key /home/alexd/.ssh/id_rsa.pub
        END
        )
        #  echo "$YC"
        eval "$YC"
        }

        create_vm "cp1"
        create_vm "node1"
        create_vm "node2"
        create_vm "node3"
        create_vm "node4"

Машины будут прерываемые, со 100% долями CPU. 

По итогу получаем следуюшие IP-адреса:

    name: cp1
    primary_v4_address:
        address: 10.128.0.20
        one_to_one_nat:
        address: 84.201.134.139

    name: node1
    primary_v4_address:
        address: 10.128.0.24
        one_to_one_nat:
        address: 84.201.130.228

    name: node2
    primary_v4_address:
        address: 10.128.0.4
        one_to_one_nat:
        address: 62.84.118.203

    name: node3
    primary_v4_address:
        address: 10.128.0.8
        one_to_one_nat:
        address: 62.84.116.185

    name: node4
    primary_v4_address:
        address: 10.128.0.10
        one_to_one_nat:
        address: 84.201.173.4

**По умолчанию, при создании VM и добавлении ключа SSH используется пользователь yc-user!**
___
##### 2. Подготовка к установке Kubernetes с помощью kubespray

- 2.1 Клонирование репозитория и установка зависимостей:

Клонируем репозиторий:

        git clone https://github.com/kubernetes-sigs/kubespray
        Cloning into 'kubespray'...
        remote: Enumerating objects: 59138, done.
        remote: Counting objects: 100% (889/889), done.
        remote: Compressing objects: 100% (520/520), done.
        remote: Total 59138 (delta 329), reused 723 (delta 266), pack-reused 58249R
        Receiving objects: 100% (59138/59138), 17.43 MiB | 2.69 MiB/s, done.
        Resolving deltas: 100% (33207/33207), done.

Установка зависимостей
`sudo pip3 install -r requirements-2.10.txt`

Копирование примера в папку с вашей конфигурацией
`cp -rfp inventory/sample inventory/mycluster`

- 2.2 Создаем `host.yml` и задаем необходимые параметры:

Для создания файла `host.yml` используем декларативный подход с помощью команды `declare`:

    declare -a IPS=(84.201.134.139 84.201.130.228 62.84.118.203 62.84.116.185 84.201.173.4)
    CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}

    DEBUG: Adding group all
    DEBUG: Adding group kube_control_plane
    DEBUG: Adding group kube_node
    DEBUG: Adding group etcd
    DEBUG: Adding group k8s_cluster
    DEBUG: Adding group calico_rr
    DEBUG: adding host node1 to group all
    DEBUG: adding host node2 to group all
    DEBUG: adding host node3 to group all
    DEBUG: adding host node4 to group all
    DEBUG: adding host node5 to group all
    DEBUG: adding host node1 to group etcd
    DEBUG: adding host node2 to group etcd
    DEBUG: adding host node3 to group etcd
    DEBUG: adding host node1 to group kube_control_plane
    DEBUG: adding host node2 to group kube_control_plane
    DEBUG: adding host node1 to group kube_node
    DEBUG: adding host node2 to group kube_node
    DEBUG: adding host node3 to group kube_node
    DEBUG: adding host node4 to group kube_node
    DEBUG: adding host node5 to group kube_node

Появился файл `host.yml`, редактируем его:

##### Примечание: 
Etcd будет находится на control node

    all:
    hosts:
        cp1:
        ansible_host: 84.201.134.139
        ip: 84.201.134.139
        #access_ip: 84.201.134.139
        node1:
        ansible_host: 84.201.130.228
        ip: 84.201.130.228
        #access_ip: 84.201.130.228
        node2:
        ansible_host: 62.84.118.203
        ip: 62.84.118.203
        #access_ip: 62.84.118.203
        node3:
        ansible_host: 62.84.116.185
        ip: 62.84.116.185
        #access_ip: 62.84.116.185
        node4:
        ansible_host: 84.201.173.4
        ip: 84.201.173.4
        #access_ip: 84.201.173.4
    children:
        kube_control_plane:
        hosts:
            cp1:
        kube_node:
        hosts:
            node1:
            node2:
            node3:
            node4:
        etcd:
        hosts:
            cp1:
        k8s_cluster:
        children:
            kube_control_plane:
            kube_node:
        calico_rr:
        hosts: {}

- 2.3 Добавим вшений доступ через Loadbalancer:

По умолчанию, подключиться к данному кластеру извне не получится, поэтому, необходимо указать IP-адрес и порт для подключения через Loadbalancer.

В разделе `mycluster` ->` group_vars` ->`all` в файле `all.yml` интересует параметр `loadbalancer_apiserver`:

    ## External LB example config
    ## apiserver_loadbalancer_domain_name: "elb.some.domain"
    loadbalancer_apiserver:
    address: 84.201.134.139
    port: 6443

Устанавливаем внешний IP-адрес Control Node.

- 2.4 Смотрим настройки `Container runtime` для установки в качестве CRI `containerd`:

В разделе `mycluster` ->`group_vars` ->`k8s_cluster` в файле `k8s-cluster.yml`

    ## Container runtime
    ## docker for docker, crio for cri-o and containerd for containerd.
    ## Default: containerd
    container_manager: containerd

**По итогу, `container_manager` уже по умолчанию установлен в качестве `containerd`**

- 2.5. Предварительно, необходимо будет подключиться к каждой созданной VM через `SSH yc-user@<IP>`, чтобы добавить эти машины в `ssh known_hosts`, иначе Ansible не сможет подключиться к удаленным машинам.
___
##### 3. Устанвока Kubernetes с помощью kubespray:

Для установки используем следующую команду:

`ansible-playbook -i inventory/mycluster/hosts.yaml --become -u=yc-user cluster.yml -vv`

    PLAY RECAP ********************************************************************************************cp1                        : ok=679  changed=144  unreachable=0    failed=0    skipped=1149 rescued=0  
    ignored=3   
    localhost                  : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0  
    ignored=0
    node1                      : ok=448  changed=88   unreachable=0    failed=0    skipped=649  rescued=0  
    ignored=1   
    node2                      : ok=448  changed=88   unreachable=0    failed=0    skipped=649  rescued=0  
    ignored=1   
    node3                      : ok=448  changed=88   unreachable=0    failed=0    skipped=649  rescued=0  
    ignored=1   
    node4                      : ok=448  changed=88   unreachable=0    failed=0    skipped=649  rescued=0  
    ignored=1   

**Примечание:**
Ключ `-u=yc-user` позволяет нам выполнять подключение под данным пользователем, так как у нас все машины были созданы ранее по этому пользователю

Ключ `--become` - необходим для повышения прав на ряд изменений на машинах (пример, смена hostname), без которого Ansible playbook выдаст ошибку (при условии, что мы запускаем не от root) 
___
##### 4. Проверяем доступность кластера c `Control Node`:

На `Control Node` переключаемся на пользователя `root`(так как под ним был создан `config` файл) и подаем команду `kubectl cluster-info` и `kubctl get node`:

    root@cp1:/home/yc-user# kubectl cluster-info
    Kubernetes control plane is running at https://lb-apiserver.kubernetes.local:6443

    To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.


    root@cp1:/home/yc-user# kubectl get node
    NAME    STATUS   ROLES                  AGE     VERSION
    cp1     Ready    control-plane,master   9m58s   v1.23.2
    node1   Ready    <none>                 8m46s   v1.23.2
    node2   Ready    <none>                 8m47s   v1.23.2
    node3   Ready    <none>                 8m47s   v1.23.2
    node4   Ready    <none>                 8m47s   v1.23.2

**Доступ к кластеру есть! Ноды подключены и в статусе Ready**
___
##### 5. Проверяем доступность кластера с локального ПК:

5.1 Копируем файл содержимое файла с `Control Node` `root@cp1:/home/yc-user# cat ~/.kube/config` на локальную машину `~/.kube/config`

Меняем значение `server: https://84.201.134.139:6443` на внешний IP-адрес `Control Node`.

    alexd@DESKTOP-92FN9PG:~$ kubectl cluster-info
    Kubernetes control plane is running at https://84.201.134.139:6443

    To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.


    alexd@DESKTOP-92FN9PG:~$ kubectl get nodes
    NAME    STATUS   ROLES                  AGE   VERSION
    cp1     Ready    control-plane,master   24m   v1.23.2
    node1   Ready    <none>                 23m   v1.23.2
    node2   Ready    <none>                 23m   v1.23.2
    node3   Ready    <none>                 23m   v1.23.2
    node4   Ready    <none>                 23m   v1.23.2

**Кластер доступен!**

___

**UPD:** В облаке YC после перезагрузки перестают создаваться pod.

Проблема заключается в `/etc/hosts`, который имеет вид после установки через `kuberspray`:

        root@cp1:/home/yc-user# cat /etc/hosts
        # Your system has configured 'manage_etc_hosts' as True.
        # As a result, if you wish for changes to this file to persist
        # then you will need to either
        # a.) make changes to the master file in /etc/cloud/templates/hosts.debian.tmpl      
        # b.) change or remove the value of 'manage_etc_hosts' in
        #     /etc/cloud/cloud.cfg or cloud-config from user-data
        #
        127.0.1.1 fhmdt3ip81auq46h720q.auto.internal fhmdt3ip81auq46h720q
        127.0.0.1 localhost localhost.localdomain

        # The following lines are desirable for IPv6 capable hosts
        ::1 ip6-localhost ip6-loopback localhost6 localhost6.localdomain
        ff02::1 ip6-allnodes
        ff02::2 ip6-allrouters

        # Ansible inventory hosts BEGIN
        10.128.0.16 cp1.cluster.local cp1
        10.128.0.20 node1.cluster.local node1
        # Ansible inventory hosts END
        51.250.12.188 lb-apiserver.kubernetes.local



        root@node1:/home/yc-user# cat /etc/hostname 
        node1
        root@node1:/home/yc-user# cat /etc/hosts
        # Your system has configured 'manage_etc_hosts' as True.
        # As a result, if you wish for changes to this file to persist
        # then you will need to either
        # a.) make changes to the master file in /etc/cloud/templates/hosts.debian.tmpl      
        # b.) change or remove the value of 'manage_etc_hosts' in
        #     /etc/cloud/cloud.cfg or cloud-config from user-data
        #
        127.0.1.1 fhm22ho1nvnqisr2dfco.auto.internal fhm22ho1nvnqisr2dfco
        127.0.0.1 localhost localhost.localdomain

        # The following lines are desirable for IPv6 capable hosts
        ::1 ip6-localhost ip6-loopback localhost6 localhost6.localdomain
        ff02::1 ip6-allnodes
        ff02::2 ip6-allrouters

        # Ansible inventory hosts BEGIN
        10.128.0.16 cp1.cluster.local cp1
        10.128.0.20 node1.cluster.local node1
        # Ansible inventory hosts END
        51.250.12.188 lb-apiserver.kubernetes.local

Погуглив нашел информацию, что многие облачные провайдеры используют модуль `cloud-ini`, который позволяет во время старта машины "собирать нужную инфу" и в том числе заменяет /etc/hosts своим шаблоном из `/etc/cloud/templates/hosts.debian.tmpl`  (вместо debian может быть другое семейство ОС). 

Соответственно, после перезапуска машины в облаке, cloud-ini возьмёт этот шаблон и "перезапишет" его в /etc/hosts.

Более детально можно посмотреть по ссылке: https://intl.cloud.tencent.com/document/product/213/32504


Пришлось редактировать шаблон по формату:


        root@cp1:/home/yc-user# cat /etc/cloud/templates/hosts.debian.tmpl 
        ## template:jinja
        {#
        This file (/etc/cloud/templates/hosts.debian.tmpl) is only utilized
        if enabled in cloud-config.  Specifically, in order to enable it
        you need to add the following to config:
        manage_etc_hosts: True
        -#}
        # Your system has configured 'manage_etc_hosts' as True.
        # As a result, if you wish for changes to this file to persist
        # then you will need to either
        # a.) make changes to the master file in /etc/cloud/templates/hosts.debian.tmpl      
        # b.) change or remove the value of 'manage_etc_hosts' in
        #     /etc/cloud/cloud.cfg or cloud-config from user-data
        #
        {# The value '{{hostname}}' will be replaced with the local-hostname -#}
        127.0.1.1 {{fqdn}} {{hostname}}
        127.0.0.1 localhost localhost.localdomain

        # The following lines are desirable for IPv6 capable hosts
        ::1 ip6-localhost ip6-loopback localhost6 localhost6.localdomain
        ff02::1 ip6-allnodes
        ff02::2 ip6-allrouters

        # Ansible inventory hosts BEGIN
        10.128.0.16 cp1.cluster.local cp1
        10.128.0.20 node1.cluster.local node1
        # Ansible inventory hosts END
        51.250.12.188 lb-apiserver.kubernetes.local