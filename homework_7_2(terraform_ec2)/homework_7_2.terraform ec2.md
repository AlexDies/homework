## Домашнее задание к занятию "7.2. Облачные провайдеры и синтаксис Терраформ."
___
Зачастую разбираться в новых инструментах гораздо интересней понимая то, как они работают изнутри. Поэтому в рамках первого необязательного задания предлагается завести свою учетную запись в AWS (Amazon Web Services).

**Задача 1. Регистрация в aws и знакомство с основами (необязательно, но крайне желательно).**

Остальные задания можно будет выполнять и без этого аккаунта, но с ним можно будет увидеть полный цикл процессов.

AWS предоставляет достаточно много бесплатных ресурсов в первых год после регистрации, подробно описано здесь.

1. Создайте аккаут aws.
2. Установите c aws-cli https://aws.amazon.com/cli/.
3. Выполните первичную настройку aws-sli https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html.
4. Создайте IAM политику для терраформа c правами 
  - AmazonEC2FullAccess
  - AmazonS3FullAccess
  - AmazonDynamoDBFullAccess
  - AmazonRDSFullAccess
  - CloudWatchFullAccess
  - IAMFullAccess
5. Добавьте переменные окружения

        export AWS_ACCESS_KEY_ID=(your access key id)
        export AWS_SECRET_ACCESS_KEY=(your secret access key)

6. Создайте, остановите и удалите ec2 инстанс (любой с пометкой `free tier`) через веб интерфейс.

В виде результата задания приложите вывод команды `aws configure list`.

___
**Выполнение ДЗ:**

1. Аккаунт создан
2. Установка aws-cli:
   
        vagrant@vagrant:~/awscli$ unzip awscliv2.zip
        Archive:  awscliv2.zip
        
        vagrant@vagrant:~/awscli$ sudo ./aws/install
        You can now run: /usr/local/bin/aws --version
        
        vagrant@vagrant:~/awscli$ aws --version
        aws-cli/2.2.27 Python/3.8.8 Linux/5.4.0-58-generic exe/x86_64.ubuntu.20 prompt/off
3. Первичная настройка:
 - Создаем пользователя `awstest` через web-интерфейс
 - Подаем команду aws configure и указываем первичные настройки:

        AWS Access Key ID [None]: AKIA2CTVW2IU5IMGYP35
        AWS Secret Access Key [None]: 6lv73Re***********
        Default region name [None]: eu-west-2
        Default output format [None]: yaml
4. Создание IAM политики для терраформа:
Добавлены политики для пользователя `awstest`
![img_1.png](img_1.png)
5. Добавление переменных окружения:

        vagrant@vagrant:~/awscli$ export AWS_ACCESS_KEY_ID=AKIA2CTVW2IU5IMGYP35
        vagrant@vagrant:~/awscli$ export AWS_SECRET_ACCESS_KEY=6lv73Re***********

6. Создание и остановка EC2 инстансов через WEB:
![img_2.png](img_2.png)
   
7. Результат команды `aws configure list`:

        vagrant@vagrant:~/awscli$ aws configure list
              Name                    Value             Type    Location
              ----                    -----             ----    --------
           profile                <not set>             None    None
        access_key     ****************YP35              env
        secret_key     ****************1pyZ              env
            region                eu-west-2      config-file    ~/.aws/config

___
**Задача 2. Созданием ec2 через терраформ.**

1. В каталоге `terraform` вашего основного репозитория, который был создан в начале курсе, создайте файл `main.tf` и `versions.tf`.
2. Зарегистрируйте провайдер для aws. В файл `main.tf` добавьте блок `provider`, а в `versions.tf` блок `terraform` с вложенным блоком `required_providers`. 
   Укажите любой выбранный вами регион внутри блока `provider`.
3. Внимание! В гит репозиторий нельзя пушить ваши личные ключи доступа к аккаунта. Поэтому в предыдущем задании мы указывали их в виде переменных окружения.
4. В файле `main.tf` воспользуйтесь блоком `data "aws_ami"` для поиска ami образа последнего Ubuntu.
5. В файле `main.tf` создайте рессурс ec2 instance. Постарайтесь указать как можно больше параметров для его определения. 
   Минимальный набор параметров указан в первом блоке `Example Usage`, но желательно, указать большее количество параметров.
6. Добавьте data-блоки `aws_caller_identity` и `aws_region`.
7. В файл `outputs.tf `поместить блоки `output` с данными об используемых в данный момент:
   - AWS account ID,
   - AWS user ID,
   - AWS регион, который используется в данный момент,
   - Приватный IP ec2 инстансы,
   - Идентификатор подсети в которой создан инстанс.
8. Если вы выполнили первый пункт, то добейтесь того, что бы команда `terraform plan` выполнялась без ошибок.

В качестве результата задания предоставьте:

1. Ответ на вопрос: при помощи какого инструмента (из разобранных на прошлом занятии) можно создать свой образ ami?
2. Ссылку на репозиторий с исходной конфигурацией терраформа.
___
**Выполнение ДЗ:**

1,2,3. Создание и наполнение файла `main.tf` и `versions.tf`:

Для `main.tf`:

        provider "aws" {
          region = "eu-west-2"
        }

Для `versions.tf`:

        terraform {
          required_providers {
            aws = {
              source  = "hashicorp/aws"
              version = "~> 3.0"
            }
          }
        }

4. Создание блока `data "aws_ami"`:
       
        data "aws_ami" "ubuntu" {
          most_recent = true
        
          filter {
            name   = "name"
            values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
          }
        
          filter {
            name   = "virtualization-type"
            values = ["hvm"]
          }
        
          owners = ["099720109477"] # Canonical
        }
   
5. Добавление ресурса инстанс EC2:

        resource "aws_instance" "test" {
          ami           = data.aws_ami.ubuntu.id
          instance_type = "t3.micro"
        
          tags = {
            Name = "testubuntu"
          }
        
           credit_specification {
             cpu_credits = "unlimited"
          }
        }
   
6. Добавление data-блоки `aws_caller_identity` и `aws_region`

        data "aws_caller_identity" "current" {}
        
        data "aws_region" "current" {}

7. Создание файла `outputs.tf`:

        output "account_id" {
          value = data.aws_caller_identity.current.account_id
        }
        
        output "caller_arn" {
          value = data.aws_caller_identity.current.arn
        }
        
        output "caller_user" {
          value = data.aws_caller_identity.current.user_id
        }
        
        output "region_name" {
          value = data.aws_region.current.name
        }
        
        output "private_ip" {
          value = aws_instance.test.private_ip
        }
        
        output "subnet_id" {
          value = aws_instance.test.subnet_id
        }

**P.S. Возник вопрос, изначально мучался добавлять private_ip и subnet_id аналогичным образом в формате data.aws_instance.test.x.
Но выдавало ошибку. Получается, формат data.x.x для output используется только если мы объявляли ранее определенный блок data?**

**Для блока ресурсов он уже не применяется и мы обращаемся к нему напрямую, верно?**

8. Вывод команды `terraform plan`:
   
        vagrant@vagrant:~/terraform/iac7_2$ terraform plan
        
        Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
          + create
        
        Terraform will perform the following actions:
        
          # aws_instance.test will be created
          + resource "aws_instance" "test" {
              + ami                                  = "ami-0230a6736b38ae83e"
              + arn                                  = (known after apply)
              + associate_public_ip_address          = (known after apply)
              + availability_zone                    = (known after apply)
              + cpu_core_count                       = (known after apply)
              + cpu_threads_per_core                 = (known after apply)
              + disable_api_termination              = (known after apply)
              + ebs_optimized                        = (known after apply)
              + get_password_data                    = false
              + host_id                              = (known after apply)
              + id                                   = (known after apply)
              + instance_initiated_shutdown_behavior = (known after apply)
              + instance_state                       = (known after apply)
              + instance_type                        = "t3.micro"
              + ipv6_address_count                   = (known after apply)
              + ipv6_addresses                       = (known after apply)
              + key_name                             = (known after apply)
              + monitoring                           = (known after apply)
              + outpost_arn                          = (known after apply)
              + password_data                        = (known after apply)
              + placement_group                      = (known after apply)
              + primary_network_interface_id         = (known after apply)
              + private_dns                          = (known after apply)
              + private_ip                           = (known after apply)
              + public_dns                           = (known after apply)
              + public_ip                            = (known after apply)
              + secondary_private_ips                = (known after apply)
              + security_groups                      = (known after apply)
              + source_dest_check                    = true
              + subnet_id                            = (known after apply)
              + tags                                 = {
                  + "Name" = "testubuntu"
                }
              + tags_all                             = {
                  + "Name" = "testubuntu"
                }
              + tenancy                              = (known after apply)
              + user_data                            = (known after apply)
              + user_data_base64                     = (known after apply)
              + vpc_security_group_ids               = (known after apply)
        
              + capacity_reservation_specification {
                  + capacity_reservation_preference = (known after apply)
        
                  + capacity_reservation_target {
                      + capacity_reservation_id = (known after apply)
                    }
                }
        
              + credit_specification {
                  + cpu_credits = "unlimited"
                }
        
              + ebs_block_device {
                  + delete_on_termination = (known after apply)
                  + device_name           = (known after apply)
                  + encrypted             = (known after apply)
                  + iops                  = (known after apply)
                  + kms_key_id            = (known after apply)
                  + snapshot_id           = (known after apply)
                  + tags                  = (known after apply)
                  + throughput            = (known after apply)
                  + volume_id             = (known after apply)
                  + volume_size           = (known after apply)
                  + volume_type           = (known after apply)
                }
        
              + enclave_options {
                  + enabled = (known after apply)
                }
        
              + ephemeral_block_device {
                  + device_name  = (known after apply)
                  + no_device    = (known after apply)
                  + virtual_name = (known after apply)
                }
        
              + metadata_options {
                  + http_endpoint               = (known after apply)
                  + http_put_response_hop_limit = (known after apply)
                  + http_tokens                 = (known after apply)
                }
        
              + network_interface {
                  + delete_on_termination = (known after apply)
                  + device_index          = (known after apply)
                  + network_interface_id  = (known after apply)
                }
        
              + root_block_device {
                  + delete_on_termination = (known after apply)
                  + device_name           = (known after apply)
                  + encrypted             = (known after apply)
                  + iops                  = (known after apply)
                  + kms_key_id            = (known after apply)
                  + tags                  = (known after apply)
                  + throughput            = (known after apply)
                  + volume_id             = (known after apply)
                  + volume_size           = (known after apply)
                  + volume_type           = (known after apply)
                }
            }
        
        Plan: 1 to add, 0 to change, 0 to destroy.
        
        Changes to Outputs:
          + account_id  = "692810338857"
          + caller_arn  = "arn:aws:iam::692810338857:user/awsuser"
          + caller_user = "AIDA2CTVW2IU67CF67QBP"
          + private_ip  = (known after apply)
          + region_name = "eu-west-2"
          + subnet_id   = (known after apply)


Ответы на вопросы:

1. Можно использовать инструмент Packer для создания собственных Ami образов.
2. Ссылка на репозиторий: https://github.com/AlexDies/homework/tree/main/homework_7_2(terraform_ec2)