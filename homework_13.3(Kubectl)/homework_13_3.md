# Домашнее задание к занятию "13.3 работа с kubectl"
## Задание 1: проверить работоспособность каждого компонента
Для проверки работы можно использовать 2 способа: port-forward и exec. Используя оба способа, проверьте каждый компонент:
* сделайте запросы к бекенду;
* сделайте запросы к фронту;
* подключитесь к базе данных.

## Задание 2: ручное масштабирование
При работе с приложением иногда может потребоваться вручную добавить пару копий. Используя команду kubectl scale, попробуйте увеличить количество бекенда и фронта до 3. После уменьшите количество копий до 1. Проверьте, на каких нодах оказались копии после каждого действия (kubectl describe).

___
## Выполнение ДЗ:

## Задание 1: проверить работоспособность каждого компонента

### 1.1 Проверка с помощью `exec`:

1) Проверка компонента `Frontend` используя команду `kubectl exec frontend-cb9bff95f-bmpnw -- curl -s localhost:80`:

        kubectl exec frontend-cb9bff95f-bmpnw -- curl -s localhost:80

        <!DOCTYPE html>
        <html lang="ru">
        <head>
            <title>Список</title>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <link href="/build/main.css" rel="stylesheet">
        </head>
        <body>
            <main class="b-page">
                <h1 class="b-page__title">Список</h1>
                <div class="b-page__content b-items js-list"></div>
            </main>
            <script src="/build/main.js"></script>
        </body>
        </html>

Отображение страницы с `frontend` работает

2) Проверка компонента `Backend` используя команду `kubectl exec backend-59f97ccdff-ckk45 -- curl -s localhost:9000/api/news/1` :

        kubectl exec backend-59f97ccdff-ckk45 -- curl -s localhost:9000/api/news/1

        {"id":1,"title":"title 0","short_description":"small text 0small text 0small text 0small text 
        0small text 0small text 0small text 0small text 0small text 0small text 0","description":"0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more 
        text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 
        some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 
        0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more 
        text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 
        some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 
        0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, 0 some more text, ","preview":"/static/image.png"

Вывод информации из `Backend` через API-вызов `/api/news/1` работает.

3) Проверка компонента `DB`:

Используем дополнительный под `multitool` для проверки подключения к ДБ через `psql`.

Подаем команду `kubectl exec -ti multitool-55974d5464-5wpn8 -- psql postgres://postgres:postgres@postgres:5432/news`

        kubectl exec -ti multitool-55974d5464-5wpn8 -- psql postgres://postgres:postgres@postgres:5432/news
        psql (13.4, server 13.5)
        Type "help" for help.

        news=# 

Подключение к ДБ `postgres news` работает и устанавливается
___
### 1.2 Проверка с помощью `port-forward`:

1) Проверка компонента `Frontend`:

Подадим команду `kubectl port-forward frontend-7d475c98ff-9pswz 8000:80` 

        kubectl port-forward frontend-7d475c98ff-9pswz 8000:80

        Forwarding from 127.0.0.1:8000 -> 80
        Forwarding from [::1]:8000 -> 80
        Handling connection for 8000
        Handling connection for 8000
        Handling connection for 8000

Запустим браузер и постучимся на `localhost:8000/detail/1/`

![front.jpg](front.jpg)

Доступ есть, информация по объекту выводится!

2) Проверка компонента `Backend`:

Подадим команду `kubectl port-forward backend-59f97ccdff-4hd4q 9000:9000` 

        kubectl port-forward backend-59f97ccdff-4hd4q 9000:9000

        Forwarding from 127.0.0.1:9000 -> 9000
        Forwarding from [::1]:9000 -> 9000
        Handling connection for 9000
        Handling connection for 9000
        Handling connection for 9000
        Handling connection for 9000

Запустим браузер и постучимся на `localhost:9000/api/news/`

![back.jpg](back.jpg)

Доступ есть, информация выдается по API

3) Проверка компонента `DB`:

Используем команду `kubectl port-forward postgres-0 5432:5432`

        kubectl port-forward postgres-0 5432:5432

        Forwarding from 127.0.0.1:5432 -> 5432
        Forwarding from [::1]:5432 -> 5432
        Handling connection for 5432
        Handling connection for 5432
        Handling connection for 5432

Далее воспользуемся подключением к ДБ через VSCode, подключаясь на `localhost:5432`

![db.jpg](db.jpg)

Доступ к ДБ есть!
___
## Задание 2: ручное масштабирование

### 2.1 Увеличим количество реплик `frontend` и `backend` до 3-х:

Подадим следующие команды:

`kubectl scale --replicas=3 deployment backend`

`kubectl scale --replicas=3 deployment frontend`

Проверим количество запущенных подов:

        kubectl get pods

        NAME                                  READY   STATUS    RESTARTS        AGE
        backend-59f97ccdff-4hd4q              1/1     Running   0               105m
        backend-59f97ccdff-4s98j              1/1     Running   0               15s
        backend-59f97ccdff-72x7q              1/1     Running   0               15s
        frontend-7d475c98ff-8dsz8             1/1     Running   0               5s
        frontend-7d475c98ff-9pswz             1/1     Running   0               105m
        frontend-7d475c98ff-r9xb8             1/1     Running   0               5s
        multitool-55974d5464-5wpn8            1/1     Running   1 (6h19m ago)   3d5h
        nfs-server-nfs-server-provisioner-0   1/1     Running   0               4h26m
        postgres-0                            1/1     Running   0               105m

### 2.2 Уменьгим количество реплик `frontend` и `backend` до 1:

Подадим следующие команды:

`kubectl scale --replicas=1 deployment backend`

`kubectl scale --replicas=1 deployment frontend`

Проверим количество запущенных подов:

        kubectl get pods

        NAME                                  READY   STATUS    RESTARTS        AGE
        backend-59f97ccdff-4hd4q              1/1     Running   0               107m
        frontend-7d475c98ff-9pswz             1/1     Running   0               107m
        multitool-55974d5464-5wpn8            1/1     Running   1 (6h21m ago)   3d5h
        nfs-server-nfs-server-provisioner-0   1/1     Running   0               4h28m
        postgres-0                            1/1     Running   0               107m

В итоге мы можем видеть, что машстабирование подов работает успешно!