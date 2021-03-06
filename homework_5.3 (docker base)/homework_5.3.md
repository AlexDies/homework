## Домашнее задание к занятию "5.3. Контейнеризация на примере Docker"
___
**Задача 1**

Посмотрите на сценарий ниже и ответьте на вопрос: "Подходит ли в этом сценарии использование докера? Или лучше подойдет виртуальная машина, физическая машина? Или возможны разные варианты?"

Детально опишите и обоснуйте свой выбор.

Сценарий:

    Высоконагруженное монолитное java веб-приложение;
    Go-микросервис для генерации отчетов;
    Nodejs веб-приложение;
    Мобильное приложение c версиями для Android и iOS;
    База данных postgresql используемая, как кэш;
    Шина данных на базе Apache Kafka;
    Очередь для Logstash на базе Redis;
    Elastic stack для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;
    Мониторинг-стек на базе prometheus и grafana;
    Mongodb, как основное хранилище данных для java-приложения;
    Jenkins-сервер.
___
**Выполнение ДЗ:**

**1. Высоконагруженное монолитное java веб-приложение;**

Судя по тенденции докера, то монолитное приложение чаще всего "распиливается" на несколько микросервисов. Вот их уже можно "засунуть" в докер.

То есть лучше всего использовать будет виртуальную машину. Или физическую, так как париложение высоконагруженное.

**2. Go-микросервис для генерации отчетов;**

Можно использовать докер, так как это микросервис. 

Использовать виртуальную машину или физическую машину будет избыточно.

**3. Nodejs веб-приложение;**

Можно использовать докер, это позволит оперативно провести тестирование приложения и передать с аналогичным окружением другим.

Создавать виртуальную машину и тем более физическую - нет смысла.

**4. Мобильное приложение c версиями для Android и iOS;**
   
Думаю что да, можно использовать докер. Например, тестируя работу приложения на разных ОС.

Использовать виртуальную машину или физическую машину будет избыточно.

**5. База данных postgresql используемая, как кэш;**
   
Чувствительные данные точно не стоит хранить в контейнере, лучше всего использовать отдельную физическую машину.

Если такой возможности нет, то хотя бы виртуальную с бэкапами.

**6. Шина данных на базе Apache Kafka;**
   
Не знаком детально с Apache Kafka, но предположу, что если речь идёт о шине с данными, то возможно стоит быть аккуратнее в плане докера.

Думаю можно будет использовать и докер и виртуальную машину. Использовать физическую машину мне кажется избыточным решщением.

**7. Очередь для Logstash на базе Redis;** 
   
Думаю, что да, можно использовать Docker. Но не уверен до конца. 

Также думаю, что можно это реализовать и на виртуальной машине.

**8. Elastic stack для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;**
   
Не было опыта использования. Но думаю, что можно разделить это всё на микросервисы и каждый упаковать в докер.

**9. Мониторинг-стек на базе prometheus и grafana;**

Думаю что не стоит, так как в случае чего, могут "потеряться" необходимые логи (если они важны).
Как вариант - использовать docker, но с папкой для лога "наружу". Так как grafana - это "оболочка", её думаю без проблем можно засунуть и в докер.

Также можно использовать виртуальную машину. Физическую думаю будет избыточно.

**10. Mongodb, как основное хранилище данных для java-приложения;**
Лучше не использовать докер, а использовать физическую машину, так как данные из БД всегда важны.

Также можно использовать виртуальную машину.

**11. Jenkins-сервер.**

Думаю да, можно использовать докер, так как мне кажется нет ничего критичного. (опыта работы с ним не было).


**P/S. С частью того, что есть в списке, к сожалению, не приводилось работать, знаю лишь в общих чертах и пока "поверхностно". 
Прошу, пожалуйста, посмотреть и дать комментарий к ответам, так как очень интересно знать "правильный" подход.**

___
**Задача 2**

Сценарий выполнения задачи:

- создайте свой репозиторий на докерхаб;
- выберете любой образ, который содержит апачи веб-сервер;
- создайте свой форк образа;
- реализуйте функциональность: запуск веб-сервера в фоне с индекс-страницей, содержащей HTML-код ниже:

        <html>
        <head>
        Hey, Netology
        </head>
        <body>
        <h1>I’m kinda DevOps now</h1>
        </body>
        </html>
Опубликуйте созданный форк в своем репозитории и предоставьте ответ в виде ссылки на докерхаб-репо.
___
**Выполнение ДЗ:**
1. Создал репозиторий https://hub.docker.com/repository/docker/alexdies/homework
2. Выбрал образ httpd с apache
3. Сделал его форк в Docker
4. Создал контейнер на основе образа httpd 
- Обновил индекс-страницу
- Также установил редактор nano
5. Создал новый образ в Docker на основе контейнера (alexdies/homework:test)
6. Запушил его в репозиторий по ссылке: https://hub.docker.com/layers/155511264/alexdies/homework/test/images/sha256-4d36b4b6552d6c52ee53d3f6f6646a589b81cb1df692d0b56ed5b8478852654e?context=explore

**P/S. Немного непонятным осталось, как посмотреть, что были внесены определенные изменения на слое (когда я изменил index.html и установил Nano в контейнере).**

2.1 Я посмотрел в Image Layers в Docker Hub на этом образе, но не увидел, где указаны эти изменения.
Причём путь в котором я остановился в контейнере (перед созданием образа) - указан в одном из слоёв.

2.2 Также смотрел в docker image inspect, но не вижу этих изменений (помимо пути, имени автора)

2.3 Или данные изменения не будут видны в слоях? Хотя мне кажется должны.

2.4 Знаю, что конфиги и файлы лучше хранить отдельно "за контейнером", но всё таки хотелось бы понять поэтому вопросу более детальнее :)
___
**Задача 3**

- Запустите первый контейнер из образа centos c любым тэгом в фоновом режиме, подключив папку info из текущей рабочей директории на хостовой машине в /share/info контейнера;
- Запустите второй контейнер из образа debian:latest в фоновом режиме, подключив папку info из текущей рабочей директории на хостовой машине в /info контейнера;
- Подключитесь к первому контейнеру с помощью exec и создайте текстовый файл любого содержания в /share/info ;
- Добавьте еще один файл в папку info на хостовой машине;
- Подключитесь во второй контейнер и отобразите листинг и содержание файлов в /info контейнера.
___
**Выполнение ДЗ:**
1. Запустил первый контейнер из образа centos назвав его centos.
2. Запустил второй контейнер из образа debian:latest назвав его debian.
Результат:
   
        root@vagrant:/home/vagrant/docker-test/info# docker ps
        CONTAINER ID   IMAGE          COMMAND              CREATED             STATUS          PORTS                  NAMES
        446e06c56f2c   debian         "sleep 1h"           7 seconds ago       Up 6 seconds                           debian
        713ba18e6e44   centos         "sleep 1h"           4 minutes ago       Up 4 minutes                           centos
3. Подключился к первому контейнеру centos:

        root@vagrant:/home/vagrant/docker-test/info# docker exec -ti centos bash

Создал файл test в папке /share/info:

        [root@713ba18e6e44 info]# cat test
        test
        test1
        test2
        test3
        test4
        test5

4. Добавил новый файл на хостовой машине docker_test:

        root@vagrant:/home/vagrant/docker-test/info# echo docker2 > docker_test
        root@vagrant:/home/vagrant/docker-test/info# ls
        docker_test  test

5. Подключился ко второму контейнеру debian:
   
        root@vagrant:/home/vagrant/docker-test/info# docker exec -ti debian bash
        root@446e06c56f2c:/# ls /info/
        docker_test  test
        root@446e06c56f2c:/#
Содержимое файлов:

        root@446e06c56f2c:/# cat /info/docker_test
        docker2
        root@446e06c56f2c:/# cat /info/test
        test
        test1
        test2
        test3
        test4
        test5
        
        docker!