# Домашнее задание к занятию "13.1 контейнеры, поды, deployment, statefulset, services, endpoints"
Настроив кластер, подготовьте приложение к запуску в нём. Приложение стандартное: бекенд, фронтенд, база данных. Его можно найти в папке 13-kubernetes-config.

## Задание 1: подготовить тестовый конфиг для запуска приложения
Для начала следует подготовить запуск приложения в stage окружении с простыми настройками. Требования:
* под содержит в себе 2 контейнера — фронтенд, бекенд;
* регулируется с помощью deployment фронтенд и бекенд;
* база данных — через statefulset.

## Задание 2: подготовить конфиг для production окружения
Следующим шагом будет запуск приложения в production окружении. Требования сложнее:
* каждый компонент (база, бекенд, фронтенд) запускаются в своем поде, регулируются отдельными deployment’ами;
* для связи используются service (у каждого компонента свой);
* в окружении фронта прописан адрес сервиса бекенда;
* в окружении бекенда прописан адрес сервиса базы данных.

## Задание 3 (*): добавить endpoint на внешний ресурс api
Приложению потребовалось внешнее api, и для его использования лучше добавить endpoint в кластер, направленный на это api. Требования:
* добавлен endpoint до внешнего api (например, геокодер)

___
## Выполнение ДЗ:

### Подготовка:

Подготовим `docker-образы` `frontend` и `backend`:

Соберем с помощью команды `docker build . --tag=alexdies/frontend:latest` и `docker build . --tag=alexdies/frontend:latest`

Запушим образы в dockerhub: `docker push alexdies/frontend:latest` и `docker push alexdies/backend:latest`

#### Ссылки:

https://hub.docker.com/repository/docker/alexdies/frontend

https://hub.docker.com/repository/docker/alexdies/backend
___
## Задание 1: подготовить тестовый конфиг для запуска приложения

### 1.1 Подготовим манифест для `statefull db`:

[Манифест для ДБ](TestDev/db-statefull.yaml)

    apiVersion: apps/v1
    kind: StatefulSet
    metadata:
      name: postgres
      labels:
        app: postgres
    spec:
      serviceName: "postgres"
      selector:
        matchLabels:
          app: postgres
      template:
        metadata:
          labels:
            app: postgres
        spec:
          containers:
          - name: postgres
            image: postgres:13-alpine
            imagePullPolicy: IfNotPresent
            ports:
              - containerPort: 5432
            volumeMounts:
              - name: db-volume
                mountPath: /data        
            env:
              - name: POSTGRES_PASSWORD
                value: postgres
              - name: POSTGRES_USER
                value: postgres
              - name: POSTGRES_DB
                value: news   
          volumes:
            - name: db-volume 

### 1.2 Подготовим манифест для `deployment backend и frontend`:

[Манифест для Фронтенда + Бэкенда](TestDev/back-front.yaml)

    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: frontend-backend
      labels:
        app: frontend-backend
    spec:
      selector:
        matchLabels:
          app: frontend-backend
      template:
        metadata:
          labels:
            app: frontend-backend
        spec:
          containers:
          - image: alexdies/frontend
            imagePullPolicy: IfNotPresent
            name: frontend
            ports:
            - containerPort: 80
            env:
              - name: BASE_URL
                value: http://localhost:9000
          - image: alexdies/backend
            imagePullPolicy: IfNotPresent
            name: backend
            ports:
            - containerPort: 9000
            env:
              - name: DATABASE_URL
                value: postgres://postgres:postgres@postgres:5432/news

### 1.3 Подготовим манифесты для `service` для `stateful db` и `deployment back+front`:

[Манифест для service stateful db](TestDev/db-service.yaml)

[Манифест для service deployment back+front](TestDev/back-front-service.yaml)

    apiVersion: v1
    kind: Service
    metadata:
      name: postgres
    spec:
      selector:
        app: postgres
      ports:
        - name: postgres
          port: 5432


    apiVersion: v1
    kind: Service
    metadata:
      name: frontend-backend
    spec:
      selector:
        app: frontend-backend
      ports:
        - name: front
          protocol: TCP
          port: 80
        - name: back
          protocol: TCP
          port: 9000

### 1.4 Запуск манифестов:

- Запускаем манифест с ДБ командой `kubectl apply -f db-statefull.yaml `

- Проверяем командой `kubectl get statefulsets.apps -o wide`:

      NAME       READY   AGE     CONTAINERS   IMAGES
      postgres   1/1     5m25s   postgres     postgres:13-alpine


- Запускаем манифест с `deployment` командой `kubectl apply -f back-front.yaml `

- Проверяем командой `kubectl get pods -o wide`:

      NAME                                READY   STATUS    RESTARTS   AGE   IP             NODE    NOMINATED NODE   READINESS GATES
      frontend-backend-6ddb88d955-gjkmh   2/2     Running   0          13m   10.233.90.85   node1   <none>           <none>
      multitool-55974d5464-5wpn8          1/1     Running   0          8h    10.233.90.70   node1   <none>           <none>
      postgres-0                          1/1     Running   0          14m   10.233.90.84   node1   <none>           <none>

- Запускаем манифест с `service stateful db` командой `kubectl apply -f db-service.yaml`

- Запускаем манифест с `service deployment` командой `kubectl apply -f back-front-service.yaml`

- Проверяем командой `kubectl get service` :

      NAME               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)           AGE
      frontend-backend   ClusterIP   10.233.60.182   <none>        80/TCP,9000/TCP   28m
      kubernetes         ClusterIP   10.233.0.1      <none>        443/TCP           7d11h
      postgres           ClusterIP   10.233.21.29    <none>        5432/TCP          28m

###  1.5 Проверяем работу приложения:

Для проверки воспользуемся командой port-forward. Подадим команду `kubectl port-forward frontend-backend-6ddb88d955-gjkmh 8000:80 9000:9000`

Проверяем на Localhost:8000 в браузере:
![web8000.jpg](web8000.jpg)


### На этом данное задание завершено!

___

## Задание 2: подготовить конфиг для production окружения

### 2.1 Подготовим отдельные `deployment` для `frontend` и `backend` опираясь на предыдущее задание (statefull для db уже есть):

[Манифест для frontend](Prod/front.yaml)

[Манифест для backend](Prod/back.yaml)

### 2.2 Подготовим отдельные `service` для `frontend` и `backend` опираясь на предыдущее задание (statefull для db уже есть):

[Манифест для service frontend](Prod/front-service.yaml)

[Манифест для service backend](Prod/back-service.yaml)

### 2.3 Запустим все манифесты:

Посмотрим список `service` командой `kubectl get service`:

    NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
    backend      ClusterIP   10.233.42.21   <none>        9000/TCP   79s
    frontend     ClusterIP   10.233.56.31   <none>        80/TCP     2m42s
    kubernetes   ClusterIP   10.233.0.1     <none>        443/TCP    7d12h
    postgres     ClusterIP   10.233.21.29   <none>        5432/TCP   48m

Посмотрим список запущенных `deployment` командами `kubectl get pod,deployments.apps,statefulsets`: 

    NAME                             READY   STATUS    RESTARTS   AGE
    pod/backend-79cdc5bf49-dj9zk     1/1     Running   0          6m11s
    pod/frontend-645f468959-hvg2m    1/1     Running   0          58s
    pod/multitool-55974d5464-5wpn8   1/1     Running   0          9h
    pod/postgres-0                   1/1     Running   0          28m

    NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
    deployment.apps/backend     1/1     1            1           6m11s
    deployment.apps/frontend    1/1     1            1           6m3s
    deployment.apps/multitool   1/1     1            1           9h

    NAME                        READY   AGE
    statefulset.apps/postgres   1/1     28m

### 2.4 Проверим доступность приложения через `port-forwarding` командой `kubectl port-forward frontend-645f468959-hvg2m 8080:80`

    Forwarding from 127.0.0.1:8080 -> 80
    Forwarding from [::1]:8080 -> 80
    Handling connection for 8080
    Handling connection for 8080


###  В результате на `localhost:8080` приложение доступно и выдает всю информацию!


