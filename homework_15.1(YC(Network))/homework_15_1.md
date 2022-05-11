# Домашнее задание к занятию "15.1. Организация сети"

Домашнее задание будет состоять из обязательной части, которую необходимо выполнить на провайдере Яндекс.Облако и дополнительной части в AWS по желанию. Все домашние задания в 15 блоке связаны друг с другом и в конце представляют пример законченной инфраструктуры.  
Все задания требуется выполнить с помощью Terraform, результатом выполненного домашнего задания будет код в репозитории. 

Перед началом работ следует настроить доступ до облачных ресурсов из Terraform используя материалы прошлых лекций и [ДЗ](https://github.com/netology-code/virt-homeworks/tree/master/07-terraform-02-syntax ). А также заранее выбрать регион (в случае AWS) и зону.

---
## Задание 1. Яндекс.Облако (обязательное к выполнению)

1. Создать VPC.
- Создать пустую VPC. Выбрать зону.
2. Публичная подсеть.
- Создать в vpc subnet с названием public, сетью 192.168.10.0/24.
- Создать в этой подсети NAT-инстанс, присвоив ему адрес 192.168.10.254. В качестве image_id использовать fd80mrhj8fl2oe87o4e1
- Создать в этой публичной подсети виртуалку с публичным IP и подключиться к ней, убедиться что есть доступ к интернету.
3. Приватная подсеть.
- Создать в vpc subnet с названием private, сетью 192.168.20.0/24.
- Создать route table. Добавить статический маршрут, направляющий весь исходящий трафик private сети в NAT-инстанс
- Создать в этой приватной подсети виртуалку с внутренним IP, подключиться к ней через виртуалку, созданную ранее и убедиться что есть доступ к интернету

Resource terraform для ЯО
- [VPC subnet](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_subnet)
- [Route table](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_route_table)
- [Compute Instance](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_instance)
---
## Задание 2*. AWS (необязательное к выполнению)

1. Создать VPC.
- Cоздать пустую VPC с подсетью 10.10.0.0/16.
2. Публичная подсеть.
- Создать в vpc subnet с названием public, сетью 10.10.1.0/24
- Разрешить в данной subnet присвоение public IP по-умолчанию. 
- Создать Internet gateway 
- Добавить в таблицу маршрутизации маршрут, направляющий весь исходящий трафик в Internet gateway.
- Создать security group с разрешающими правилами на SSH и ICMP. Привязать данную security-group на все создаваемые в данном ДЗ виртуалки
- Создать в этой подсети виртуалку и убедиться, что инстанс имеет публичный IP. Подключиться к ней, убедиться что есть доступ к интернету.
- Добавить NAT gateway в public subnet.
3. Приватная подсеть.
- Создать в vpc subnet с названием private, сетью 10.10.2.0/24
- Создать отдельную таблицу маршрутизации и привязать ее к private-подсети
- Добавить Route, направляющий весь исходящий трафик private сети в NAT.
- Создать виртуалку в приватной сети.
- Подключиться к ней по SSH по приватному IP через виртуалку, созданную ранее в публичной подсети и убедиться, что с виртуалки есть выход в интернет.

Resource terraform
- [VPC](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)
- [Subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)
- [Internet Gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway)

___
### Выполнение ДЗ:

#### Задание 1. Яндекс.Облако (обязательное к выполнению)

#### 1.1 Установка и настройка `terraform`:

Установим terraform из зеркала `wget https://hashicorp-releases.website.yandexcloud.net/terraform/1.1.9/terraform_1.1.9_linux_amd64.zip`

Раскапкуем и перенесём `terraform` в `/usr/bin/`

Так как провайдер `yandex-cloud` недоступен из terraform provider, нам необходимо сделать зеркало. Добавим файл `nano ~/.terraformrc` с содержимым:
```
provider_installation {
  network_mirror {
    url = "https://terraform-mirror.yandexcloud.net/"
    include = ["registry.terraform.io/*/*"]
  }
  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
}
```

Проинициализируем с помощью команды `terraform init`:
```
Initializing the backend...

- Finding latest version of yandex-cloud/yandex...
- Installing yandex-cloud/yandex v0.74.0...
- Installed yandex-cloud/yandex v0.74.0 (unauthenticated)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
```

`Terrafrom` установлен и работает успешно!

#### 1.2 Создание VPC:

Добавим в файле `main.tf` следующее:
```
resource "yandex_vpc_network" "network-test" {
  name = "network-test-vpc"
}
```
Наша VPC будет называться `network-test-vpc`.

#### 1.3 Создадим публичную подсеть, NAT-инстанс и виртуальную машину:

Создаем `vps subnet` `public` с сетью `192.168.10.0/24`

```
resource "yandex_vpc_subnet" "public" {
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.network-test.id}"
  name           = "public"
}
```
Так как в YC нет отдельного NAT-интсанса, берем готовый образ (`fd80mrhj8fl2oe87o4e1`) и создаем инстанс `nat-instance`. Указываем публичную подсеть созданную нами ранее в `subnet_id` и задаем IP-адрес `192.168.10.254`. Для выхода в публичную сеть указываем параметр `nat = true`

```
resource "yandex_compute_instance" "nat-instance" {
  name        = "nat-instance"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.public.id}"
    ip_address = "192.168.10.254"
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
```

Создаем публичную виртуальную машину `public-vm`. За основу берем образ `ubuntu (fd8db2s90v5knmg1p7dv)`, указываем `subnet_id` `public` и задаем параметр `nat = true` для получения публичного IP.

```
resource "yandex_compute_instance" "public-vm" {
  name = "public-vm"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8db2s90v5knmg1p7dv"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
```
#### 1.4 Создадим приватную подсеть, таблицу маршрутизации и виртуальную машину:

Создаем таблицу маршрутизации `nat-route`. Добавляем статический маршрут, напарвляющий весь трафик (`0.0.0.0/24`) на наш NAT-инстанс (`192.168.10.254`)

```
resource "yandex_vpc_route_table" "nat-route" {
  network_id = "${yandex_vpc_network.network-test.id}"

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "192.168.10.254"
  }
}
```

Создаем `vps subnet` `private` с сетью `192.168.20.0/24`, добавляем таблицу маршрутизации `nat-route` в `route_table_id`
```
resource "yandex_vpc_subnet" "private" {
  v4_cidr_blocks = ["192.168.20.0/24"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.network-test.id}"
  route_table_id = "${yandex_vpc_route_table.nat-route.id}"
  name           = "private"
}
```
Создаем приватную виртуальную машину `private-vm`. За основу берем образ `ubuntu (fd8db2s90v5knmg1p7dv)`, указываем `subnet_id` `private` 

```
resource "yandex_compute_instance" "private-vm" {
  name = "private-vm"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8db2s90v5knmg1p7dv"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private.id
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
```

###### Итоговый файл [main.tf](main.tf) 

#### 1.5 Проверяем доступность:

- Подключаемся к публичной машине (`public-vm`) по статическому IP-адресу (`51.250.89.70`) и проверяем доступ в сеть Интернет:
```
ssh -A ubuntu@51.250.89.70
Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.4.0-42-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage
Last login: Wed May 11 20:20:16 2022 from 95.31.160.141
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.


ubuntu@fhmmuc3m28n6s3uc8o18:~$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=61 time=18.5 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=61 time=17.9 ms
^C
--- 8.8.8.8 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 17.855/18.158/18.461/0.303 ms
```
Доступ есть!

- Подключаемся из публичной машине(`public-vm`) к приватной машине(`private-vm`) по SSH и проверяем доступность во внешнюю сеть Интернет:
```
ubuntu@fhmmuc3m28n6s3uc8o18:~$ ssh 192.168.20.25
Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.4.0-42-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage
Last login: Wed May 11 20:20:41 2022 from 192.168.10.32
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.


ubuntu@fhmv2th3lcg28m1p8fdq:~$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=59 time=16.9 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=59 time=15.9 ms
^C
--- 8.8.8.8 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 15.900/16.424/16.948/0.524 ms
```

На этом задание считаем выполненымю