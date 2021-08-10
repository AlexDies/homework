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
4. В файле `main.tf` воспользуйтесь блоком `data "aws_ami` для поиска ami образа последнего Ubuntu.
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

