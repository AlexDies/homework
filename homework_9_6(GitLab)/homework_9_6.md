# Домашнее задание к занятию "09.06 Gitlab"

## Подготовка к выполнению

1. Необходимо [зарегистрироваться](https://about.gitlab.com/free-trial/)
2. Создайте свой новый проект
3. Создайте новый репозиторий в gitlab, наполните его [файлами](./repository)
4. Проект должен быть публичным, остальные настройки по желанию

## Основная часть

### DevOps

В репозитории содержится код проекта на python. Проект - RESTful API сервис. Ваша задача автоматизировать сборку образа с выполнением python-скрипта:
1. Образ собирается на основе [centos:7](https://hub.docker.com/_/centos?tab=tags&page=1&ordering=last_updated)
2. Python версии не ниже 3.7
3. Установлены зависимости: `flask` `flask-jsonpify` `flask-restful`
4. Создана директория `/python_api`
5. Скрипт из репозитория размещён в /python_api
6. Точка вызова: запуск скрипта
7. Если сборка происходит на ветке `master`: Образ должен пушится в docker registry вашего gitlab `python-api:latest`, иначе этот шаг нужно пропустить

### Product Owner

Вашему проекту нужна бизнесовая доработка: необходимо поменять JSON ответа на вызов метода GET `/rest/api/get_info`, необходимо создать Issue в котором указать:
1. Какой метод необходимо исправить
2. Текст с `{ "message": "Already started" }` на `{ "message": "Running"}`
3. Issue поставить label: feature

### Developer

Вам пришел новый Issue на доработку, вам необходимо:
1. Создать отдельную ветку, связанную с этим issue
2. Внести изменения по тексту из задания
3. Подготовить Merge Requst, влить необходимые изменения в `master`, проверить, что сборка прошла успешно


### Tester

Разработчики выполнили новый Issue, необходимо проверить валидность изменений:
1. Поднять докер-контейнер с образом `python-api:latest` и проверить возврат метода на корректность
2. Закрыть Issue с комментарием об успешности прохождения, указав желаемый результат и фактически достигнутый

## Итог

После успешного прохождения всех ролей - отправьте ссылку на ваш проект в гитлаб, как решение домашнего задания

## Необязательная часть

Автомазируйте работу тестировщика, пусть у вас будет отдельный конвейер, который автоматически поднимает контейнер и выполняет проверку, например, при помощи curl. На основе вывода - будет приниматься решение об успешности прохождения тестирования
___
## Выполнение ДЗ:

### Подготовка к выполнению

1. Регистрация в gitlab
2. Создан проект: `https://gitlab.com/alex1094/alexdnetologyhomework`
3. Создан новый репозиторий в gitlab с файлом `python-api.py` `https://gitlab.com/alex1094/alexdnetologyhomework/-/tree/main`
4. Проект публичный и доступный извне
___
## Основная часть
___
### DevOps

1,2,3,4,5,6. Создан `dockerfile` с содержанием:

            FROM centos:7

            RUN yum update -y && yum install -y python3 python3-pip
            RUN pip3 install flask flask_restful flask_jsonpify

            ADD python-api.py /python_api/python-api.py

            ENTRYPOINT ["python3", "/python_api/python-api.py"]

7. Настроена сборка на ветке `main` и пуш в docker registry gitlab `python-api:latest`:

В CI/CD добавлена сборка:

            image: docker:20.10.5
            services:
                - docker:20.10.5-dind
            stages: 
                - build
                - deploy
            build_build:
                stage: build
                script:
                    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
                    - docker build -t $CI_REGISTRY/alex1094/alexdnetologyhomework/image:latest .
                except:
                    - main
            build&deploy:
                stage: deploy
                script:
                    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
                    - docker build -t $CI_REGISTRY/alex1094/alexdnetologyhomework/python-api:latest .
                    - docker push $CI_REGISTRY/alex1094/alexdnetologyhomework/python-api:latest
                only:
                    - main

Образ успешно собран и запушен в репозиторий:

            $ docker push $CI_REGISTRY/alex1094/alexdnetologyhomework/python-api:latest
            The push refers to repository [registry.gitlab.com/alex1094/alexdnetologyhomework/python-api]
            7a220364ea68: Preparing
            5b4e9c2e973a: Preparing
            b2f9a02d5d0e: Preparing
            174f56854903: Preparing
            7a220364ea68: Pushed
            5b4e9c2e973a: Pushed
            174f56854903: Pushed
            b2f9a02d5d0e: Pushed
            latest: digest: sha256:d9968bab15136887afa875609eb69cab8877c92088afe82fce8a5d48c7bdc073 size: 1160
            Cleaning up project directory and file based variables 00:00
            Job succeeded
___
### Product Owner

1. Создана Issue с названием `Необходимо поменять JSON ответ на вызов метода GET get_info`
2. Содержит следующее:
        Исправляем метод "GET"
        Текст с { "message": "Already started" } на { "message": "Running"}
3. Добавлен `label` `feature`

___
### Developer

1. На основе полученного Issue на доработку создаем отдельную ветку `Create merge request`
Создана отдельная ветка  `1-json-get-get_info` и автоматически начат CI\CD
2. Вносим изменения в файл `python-api.py`:

        class Info(Resource):
            def get(self):
                return {'version': 3, 'method': 'GET', 'message': 'Running'}
Начался автоматический процесс CI\CD
3. В `Merge requests` выбран `Merge` с галочкой `Delete source branch`. Сборка прошла успешно и мерж выполнен.

___
### Tester

Сборка CI\CD на `main` ветке началась автоматически и пройдена успешно.

1. Скачиваем билд образа `python-api:latest` с репозитория `registry.gitlab.com/alex1094/alexdnetologyhomework/python-api `

            alexd@DESKTOP-92FN9PG:/mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook$ docker pull registry.gitlab.com/alex1094/alexdnetologyhomework/python-api:latest
            latest: Pulling from alex1094/alexdnetologyhomework/python-api
            2d473b07cdd5: Already exists
            c7c008169bb0: Pull complete
            2742baf74d93: Pull complete
            0b394cbe19d7: Pull complete
            Digest: sha256:fda112a150cf3efdb0c3569f9b37a7b61950bb749de9f515289c2bf6e5c94641
            Status: Downloaded newer image for registry.gitlab.com/alex1094/alexdnetologyhomework/python-api:latest
            registry.gitlab.com/alex1094/alexdnetologyhomework/python-api:latest

2. Запускаем контейнер:

        alexd@DESKTOP-92FN9PG:/mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook$ docker container run -p 5290:5290 -d registry.gitlab.com/alex1094/alexdnetologyhomework/python-api:latest
        6b453e2bd89c29c0aa3cf01bf3d62e10a090a907cd1af0ff81fc1d973b169622

3. Проверяем возврат метода:

            alexd@DESKTOP-92FN9PG:/mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook$ curl localhost:5290<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
            <title>404 Not Found</title>
            <h1>Not Found</h1>
            <p>The requested URL was not found on the server. If you entered the URL manually please check your spelling and try 
            again.</p>

            alexd@DESKTOP-92FN9PG:/mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook$ curl localhost:5290/get_info
            {"version": 3, "method": "GET", "message": "Running"}

Всё работает успешно, Issue закрыт с комментарием
123
