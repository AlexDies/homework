## Домашнее задание к занятию "7.1. Инфраструктура как код"
___
**Задача 1. Выбор инструментов.**

Легенда

Через час совещание на котором менеджер расскажет о новом проекте. Начать работу над которым надо будет уже сегодня. 
На данный момент известно, что это будет сервис, который ваша компания будет предоставлять внешним заказчикам. 
Первое время, скорее всего, будет один внешний клиент, со временем внешних клиентов станет больше.

Так же по разговорам в компании есть вероятность, что техническое задание еще не четкое, 
что приведет к большому количеству небольших релизов, тестирований интеграций, откатов, доработок, то есть скучно не будет.

Вам, как девопс инженеру, будет необходимо принять решение об инструментах для организации инфраструктуры. 
На данный момент в вашей компании уже используются следующие инструменты:

- остатки Сloud Formation,
- некоторые образы сделаны при помощи Packer,
- год назад начали активно использовать Terraform,
- разработчики привыкли использовать Docker,
- уже есть большая база Kubernetes конфигураций,
- для автоматизации процессов используется Teamcity,
- также есть совсем немного Ansible скриптов,
- и ряд bash скриптов для упрощения рутинных задач.

Для этого в рамках совещания надо будет выяснить подробности о проекте, что бы в итоге определиться с инструментами:

1. Какой тип инфраструктуры будем использовать для этого проекта: изменяемый или не изменяемый?
2. Будет ли центральный сервер для управления инфраструктурой?
3. Будут ли агенты на серверах?
4. Будут ли использованы средства для управления конфигурацией или инициализации ресурсов?

В связи с тем, что проект стартует уже сегодня, в рамках совещания надо будет определиться со всеми этими вопросами.

**В результате задачи необходимо**

1. Ответить на четыре вопроса представленных в разделе "Легенда".
2. Какие инструменты из уже используемых вы хотели бы использовать для нового проекта?
3. Хотите ли рассмотреть возможность внедрения новых инструментов для этого проекта?

Если для ответа на эти вопросы недостаточно информации, то напишите какие моменты уточнить на совещании.
___
**Выполнение ДЗ:**
1. Ответы на вопросы:

- Какой тип инфраструктуры будем использовать для этого проекта: изменяемый или не изменяемый?
  
Так как проект планируется с постоянными изменениями и фиксами, откатами и доработками, то вероятнее всего на данном этапе посмотреть в сторону изменяемой структуры.

Но тут зависит от деталей при обсуждении, возможно нам легче будет обновить полностью весь образ доработав код и предоставить этот образ на все системы многим клиентам сразу (я вижу это как конечный этап)

- Будет ли центральный сервер для управления инфраструктурой?

Скорее всего нет необходимости в выделении отдельного сервера, так как все можно развернуть с помощью инструментов без отдельного сервера.

Но момент немного спорный, если все управление берем на себя мы и необходимо будет этим управлять у множества клиентов в дальнейшем, то возможно стоить и рассмотреть центральный сервер.

- Будут ли агенты на серверах?

Согласно пункту выше - если у нас нет выделенного сервера, то и агенты там будут не нужны. В случае если решим делать выделенный сервер, то агенты будут нужны.

- Будут ли использованы средства для управления конфигурацией или инициализации ресурсов?

Не хватает информации по развертыванию инфраструктуры. Где будут находиться сервера с сервисом - у конечного заказчика на выделенном сервере или же где-то в облаке?

2. Какие инструменты из уже используемых вы хотели бы использовать для нового проекта?
- Packer
- Terraform
- Kubernetes
- Возможно Ansible - зависит от ответов на вопросы.

3. Хотите ли рассмотреть возможность внедрения новых инструментов для этого проекта?

Опять же зависит от ответа на дополнительные вопросы, возможно можно будет рассмотреть Puppet или Chef вместо Ansible.
Но вероятнее всего, то что уже есть - нам хватит для реализации нашего проекта. 


**P/S. При выполнении данного задания действительно возникло много вопросов в голове и нюансов. И пока нет полноценного представления что же всё же лучше.**

**- Хочется услышать мнение эксперта по данному заданию, что сделать в этом кейсе, если рассматривать его как реальный и что выбрать?**

**- Я думаю правильного варианта нет и можно решить этот кейс по-разному. Но подойдёт ли решение packet+ terraform + kuber под данный кейс или он будет избыточным?**

___
**Задача 2. Установка терраформ.**

Официальный сайт: https://www.terraform.io/

Установите терраформ при помощи менеджера пакетов используемого в вашей операционной системе. 
В виде результата этой задачи приложите вывод команды `terraform --version`.
___
**Выполнение ДЗ:**

Установил с помощью менеджера пакетов:

    vagrant@vagrant:~$ sudo apt-get install terraform
    
    Reading package lists... Done
    Building dependency tree
    Reading state information... Done
    The following NEW packages will be installed:
      terraform
    0 upgraded, 1 newly installed, 0 to remove and 153 not upgraded.
    Need to get 0 B/32.4 MB of archives.
    After this operation, 78.4 MB of additional disk space will be used.
    Selecting previously unselected package terraform.
    (Reading database ... 44324 files and directories currently installed.)
    Preparing to unpack .../terraform_1.0.3_amd64.deb ...
    Unpacking terraform (1.0.3) ...
    Setting up terraform (1.0.3) ...
    
    vagrant@vagrant:~$ sudo terraform --version
    Terraform v1.0.3
    on linux_amd64

___
**Задача 3. Поддержка легаси кода.**

В какой-то момент вы обновили терраформ до новой версии, например с 0.12 до 0.13. А код одного из проектов настолько устарел, что не может работать с версией 0.13. 
В связи с этим необходимо сделать так, чтобы вы могли одновременно использовать последнюю версию терраформа установленную при помощи штатного менеджера пакетов и устаревшую версию 0.12.

В виде результата этой задачи приложите вывод `--version` двух версий терраформа доступных на вашем компьютере или виртуальной машине.
___
**Выполнение ДЗ:**

Воспользовался специальной утилитой tfswitch:

    curl -L https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh
Далее установил разные версии Terraform:

    vagrant@vagrant:~$ tfswitch
    ✔ 0.12.0
    Downloading to: /home/vagrant/.terraform.versions
    14907580 bytes downloaded
    Switched terraform to version "0.12.0"
    
    vagrant@vagrant:~$ sudo terraform --version
    Terraform v0.12.0
    
    Your version of Terraform is out of date! The latest version
    is 1.0.3. You can update by downloading from www.terraform.io/downloads.html
    
    vagrant@vagrant:~$ tfswitch
    ✔ 1.0.3 *recent
    Switched terraform to version "1.0.3"
    
    vagrant@vagrant:~$ sudo terraform --version
    Terraform v1.0.3
    on linux_amd64