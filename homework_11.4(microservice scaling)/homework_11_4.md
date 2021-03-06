
# Домашнее задание к занятию "11.04 Микросервисы: масштабирование"

Вы работаете в крупной компанию, которая строит систему на основе микросервисной архитектуры.
Вам как DevOps специалисту необходимо выдвинуть предложение по организации инфраструктуры, для разработки и эксплуатации.

## Задача 1: Кластеризация

Предложите решение для обеспечения развертывания, запуска и управления приложениями.
Решение может состоять из одного или нескольких программных продуктов и должно описывать способы и принципы их взаимодействия.

Решение должно соответствовать следующим требованиям:
- Поддержка контейнеров;
- Обеспечивать обнаружение сервисов и маршрутизацию запросов;
- Обеспечивать возможность горизонтального масштабирования;
- Обеспечивать возможность автоматического масштабирования;
- Обеспечивать явное разделение ресурсов доступных извне и внутри системы;
- Обеспечивать возможность конфигурировать приложения с помощью переменных среды, в том числе с возможностью безопасного хранения чувствительных данных таких как пароли, ключи доступа, ключи шифрования и т.п.

Обоснуйте свой выбор.

## Задача 2: Распределенный кэш * (необязательная)

Разработчикам вашей компании понадобился распределенный кэш для организации хранения временной информации по сессиям пользователей.
Вам необходимо построить Redis Cluster состоящий из трех шард с тремя репликами.

### Схема:

![11-04-01](https://user-images.githubusercontent.com/1122523/114282923-9b16f900-9a4f-11eb-80aa-61ed09725760.png)

___
## Выполнение ДЗ:
## Задача 1: Кластеризация

Решение должно соответствовать следующим требованиям:
- Поддержка контейнеров;
- Обеспечивать обнаружение сервисов и маршрутизацию запросов;
- Обеспечивать возможность горизонтального масштабирования;
- Обеспечивать возможность автоматического масштабирования;
- Обеспечивать явное разделение ресурсов доступных извне и внутри системы;
- Обеспечивать возможность конфигурировать приложения с помощью переменных среды, в том числе с возможностью безопасного хранения чувствительных данных таких как пароли, ключи доступа, ключи шифрования и т.п.


|Требования|Kubernetes|Docker Swarm|Nomad|Apache Mesos|
|:---|:---|:---|:---|:---|
|Поддержка контейнеров|+ (В том числе поддержка решений со стандартом CRI (Container Runtime Interface)) |+|+(Он поддерживает виртуализированные, контейнерные и автономные, микросервисные и пакетные приложения, включая Docker, Java, Qemu )|+ (Могут быть как контейнерными, так и неконтейнерными)|
|Обеспечивать обнаружение сервисов и маршрутизацию запросов|+ (Использование встроенного DNS-сервера)|+ (Использование встроенного DNS-сервера)|- (Для обнаружения сервисов необходимо использовать дополнительный инструмент Consul)|+ (Mesos-DNS обеспечивает обнаружение служб и базовую балансировку нагрузки для приложений)|
|Обеспечивать возможность горизонтального масштабирования|+|+|+|+|
|Обеспечивать возможность автоматического масштабирования|+|-(Количество задач задается вручную)|+|+|
|Обеспечивать явное разделение ресурсов доступных извне и внутри системы|+|-|+|+|
|Обеспечивать возможность конфигурировать приложения с помощью переменных среды, в том числе с возможностью безопасного хранения чувствительных данных таких как пароли, ключи доступа, ключи шифрования и т.п.|+|+(Применяет взаимную аутентификацию и шифрование TLS для защиты коммуникаций внутри себя и с другими узлами)|-(Необходимость использования сторонней системы Vault для управления конфиденциальной информацией)|- (Сторонние инструменты, например Vault, либо в DC/OS Enterprise версии|


По итогу, мы можем выделить, что по всем нужным нам критериям удовлетворяет оркестратор `Kubernetes`. Собственно его и стоит рассмотреть по итогу для внедрения. Данный оркестратор стал одним из мейн-стримов и имеет большое количество комьюнити и поддержки в Интернете, что также является плюсом.