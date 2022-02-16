# Домашнее задание к занятию "13.4 инструменты для упрощения написания конфигурационных файлов. Helm и Jsonnet"
В работе часто приходится применять системы автоматической генерации конфигураций. Для изучения нюансов использования разных инструментов нужно попробовать упаковать приложение каждым из них.

## Задание 1: подготовить helm чарт для приложения
Необходимо упаковать приложение в чарт для деплоя в разные окружения. Требования:
* каждый компонент приложения деплоится отдельным deployment’ом/statefulset’ом;
* в переменных чарта измените образ приложения для изменения версии.

## Задание 2: запустить 2 версии в разных неймспейсах
Подготовив чарт, необходимо его проверить. Попробуйте запустить несколько копий приложения:
* одну версию в namespace=app1;
* вторую версию в том же неймспейсе;
* третью версию в namespace=app2.

## Задание 3 (*): повторить упаковку на jsonnet
Для изучения другого инструмента стоит попробовать повторить опыт упаковки из задания 1, только теперь с помощью инструмента jsonnet.

___
## Выполнение ДЗ:

## Задание 1: подготовить helm чарт для приложения

#### 1.1 Создадим новый `chart` `testchart` командой `helm create testchart`

Удалим не нужные сейчас файлы в папке `templates`, оставим только `deployment.yaml`, `namespace.yaml`, `service.yaml`, `statefulset.yml` Они нужны будут нам для переноса нашего приложения.

Редактирование файла `deployment.yaml`:

[Манифест Deployment](testchar/../testchart/templates/deployment.yaml)


Редактирование файла `namespace.yaml`:

[Манифест Namespace](testchar/../testchart/templates/namespace.yaml)


Редактирование файла `service.yaml`:

[Манифест Service](testchar/../testchart/templates/service.yaml)


Редактирование файла `statefulset.yaml`:

[Манифест Statefulset](testchar/../testchart/templates/StatefulSet.yaml)

Редактирование файла `value.yaml`:

[Манифест value](testchar/../testchart/values.yaml)


#### 1.2 Проверим `lint` с помощью команды `helm lint testchart/`:

        ==> Linting testchart/
        [INFO] Chart.yaml: icon is recommended

        1 chart(s) linted, 0 chart(s) failed

#### 1.3 Проверим вывод готового шаблона с помощью команды `helm template testchart`:

        ---
        # Source: testchart/templates/namespace.yaml
        apiVersion: v1
        kind: Namespace
        metadata:
        name: helm
        ---
        # Source: testchart/templates/service.yaml
        apiVersion: v1
        kind: Service
        metadata:
        name: postgres
        namespace: helm
        spec:
        selector:
            app: postgres
        ports:
            - name: postgres
            port: 5432
        ---
        # Source: testchart/templates/service.yaml
        apiVersion: v1
        kind: Service
        metadata:
        namespace: helm
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
        ---
        # Source: testchart/templates/deployment.yaml
        apiVersion: apps/v1
        kind: Deployment
        metadata:
        name: frontend-backend
        namespace: helm
        labels:
            app: frontend-backend
        spec:
        replicas: 1
        selector:
            matchLabels:
            app: frontend-backend
        template:
            metadata:
            labels:
                app: frontend-backend
            spec:
            containers:
            - image: "alexdies/frontend:latest"
                imagePullPolicy: IfNotPresent
                name: frontend
                ports:
                - containerPort: 80
                volumeMounts:
                - mountPath: /static
                name: test-volume
                env:
                - name: BASE_URL
                    value: http://localhost:9000
            - image: "alexdies/backend:latest"
                imagePullPolicy: IfNotPresent
                name: backend
                ports:
                - containerPort: 9000
                volumeMounts:
                - mountPath: /static
                name: test-volume
                env:
                - name: DATABASE_URL
                    value: postgres://postgres:postgres@postgres:5432/news
            volumes:
                - name: test-volume
                emptyDir: {}
        ---
        # Source: testchart/templates/StatefulSet.yaml
        apiVersion: apps/v1
        kind: StatefulSet
        metadata:
        name: postgres
        namespace: helm
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
                image: "postgres:13-alpine"
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

##### По итогу - всё "заменилось" как нужно, chart готов к деплою!
___
## Задание 2: запустить 2 версии в разных неймспейсах

#### 2.1 Деплоим текущую версию приложения в `namespace` `app1` с помощью команды `helm install --set namespace=app1 version1 testchart`:

        NAME: version1
        LAST DEPLOYED: Thu Feb 10 17:37:00 2022
        NAMESPACE: default
        STATUS: deployed
        REVISION: 1
        TEST SUITE: None
        NOTES:
        ---------------------------------------------------------

        Content of NOTES.txt appears after deploy.
        Deployed to app1 namespace.

        ---------------------------------------------------------

Проверим развернулось ли приложение:

        kubectl -n app1 get pod,deployments.apps,service,statefulsets.apps 

        NAME                                    READY   STATUS    RESTARTS   AGE
        pod/frontend-backend-6cc9f55c99-q6k5r   2/2     Running   0          4m14s
        pod/postgres-0                          1/1     Running   0          4m14s

        NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
        deployment.apps/frontend-backend   1/1     1            1           4m14s

        NAME                       TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)           AGE
        service/frontend-backend   ClusterIP   10.233.24.23    <none>        80/TCP,9000/TCP   4m14s
        service/postgres           ClusterIP   10.233.25.240   <none>        5432/TCP          4m14s

        NAME                        READY   AGE
        statefulset.apps/postgres   1/1     4m14s

Приложение успешно развернуто.

#### 2.2 Пробуем деплоить обновленную версию приложения в тотже `namespace` `app1` с помощью команды `helm install --set namespace=app1 version2 testchart` 

Выдает ошибку:

```
Error: INSTALLATION FAILED: rendered manifests contain a resource that already exists. Unable to continue 
with install: Namespace "app1" in namespace "" exists and cannot be imported into the current release: invalid ownership metadata; annotation validation error: key "meta.helm.sh/release-name" must equal "version2": current value is "version1"
```

###### Так как в текущем `Namespace app1` уже создано приложение первой версии(version1) и используется, то создать приложение с другим именем (version2) в этом же `Namespace` будет невозможно. 


Попробуем обновить версию в файле `Chart.yaml` и обновить, укажем `version: 0.1.2` и `appVersion: "1.18.0"`. Запускаем командой `helm upgrade --install --set namespace=app1 version2 testchart`

Получаем ошику:

        Release "version2" does not exist. Installing it now.
        Error: rendered manifests contain a resource that already exists. Unable to continue with install: Namespace "app1" in namespace "" exists and cannot be imported into the current release: invalid ownership metadata; annotation validation error: key "meta.helm.sh/release-name" must equal "version2": current value is "version1"

Пробуем обновить используя `version1` командой `helm upgrade --install --set namespace=app1 version1 testchart`

        Release "version1" has been upgraded. Happy Helming!
        NAME: version1
        LAST DEPLOYED: Thu Feb 10 17:48:44 2022
        NAMESPACE: default
        STATUS: deployed
        REVISION: 2
        TEST SUITE: None
        NOTES:
        ---------------------------------------------------------

        Content of NOTES.txt appears after deploy.
        Deployed to app1 namespace.

        ---------------------------------------------------------

Смотри деплой в `helm` с помощью `Helm list`:

        helm list
        WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: /home/alexd/.kube/config
        WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: /home/alexd/.kube/config
        NAME            NAMESPACE       REVISION        UPDATED                                 STATUS                       CHART                            APP VERSION    
        nfs-server      default         1               2022-02-08 15:27:30.0063185 +0300 MSK   deployed                     nfs-server-provisioner-1.1.3     2.3.0
        version1        default         2               2022-02-10 17:48:44.1582973 +0300 MSK   deployed                     testchart-0.1.2                  1.18.0

Версия `APP Version` обновилась до указанной `1.18.0` , `REVISION `стала равным `2`

Но по итогу, всё равно нового приложения не появилось в одном и томже `namespace` `app1`.


#### 2.3 Запустим третью версию приложения (`version3`) для `namespace app2` используя команду `helm upgrade --install --set namespace=app2 version3 testchart`

        Release "version3" does not exist. Installing it now.
        NAME: version3
        LAST DEPLOYED: Thu Feb 10 17:56:08 2022
        NAMESPACE: default
        STATUS: deployed
        REVISION: 1
        TEST SUITE: None
        NOTES:
        ---------------------------------------------------------

        Content of NOTES.txt appears after deploy.
        Deployed to app2 namespace.

        ---------------------------------------------------------

Создание прошло успешно, проверяем с помощью `helm list`:

        NAME            NAMESPACE       REVISION        UPDATED                                 STATUS                   CHART                            APP VERSION    
        nfs-server      default         1               2022-02-08 15:27:30.0063185 +0300 MSK   deployed                 nfs-server-provisioner-1.1.3     2.3.0
        version1        default         2               2022-02-10 17:48:44.1582973 +0300 MSK   deployed                 testchart-0.1.2                  1.18.0
        version3        default         1               2022-02-10 17:56:08.1082644 +0300 MSK   deployed                 testchart-0.1.2                  1.18.0

 Приложение успешно создано в другом `namespace app2 `!

        kubectl -n app2 get pod,deployments.apps,service,statefulsets.apps

        NAME                                    READY   STATUS    RESTARTS   AGE
        pod/frontend-backend-6cc9f55c99-fkvv9   2/2     Running   0          2m37s
        pod/postgres-0                          1/1     Running   0          2m37s

        NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
        deployment.apps/frontend-backend   1/1     1            1           2m37s

        NAME                       TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)           AGE
        service/frontend-backend   ClusterIP   10.233.4.26    <none>        80/TCP,9000/TCP   2m37s
        service/postgres           ClusterIP   10.233.43.32   <none>        5432/TCP          2m37s

        NAME                        READY   AGE
        statefulset.apps/postgres   1/1     2m37s

#### По итогу, делаем вывод, что запустить два приложения через `helm` на один `namespace` не получится. А вот создать приложения в разных `namespace` - получится.