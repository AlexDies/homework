# Домашнее задание к занятию "13.2 разделы и монтирование"
Приложение запущено и работает, но время от времени появляется необходимость передавать между бекендами данные. А сам бекенд генерирует статику для фронта. Нужно оптимизировать это.
Для настройки NFS сервера можно воспользоваться следующей инструкцией (производить под пользователем на сервере, у которого есть доступ до kubectl):
* установить helm: curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
* добавить репозиторий чартов: helm repo add stable https://charts.helm.sh/stable && helm repo update
* установить nfs-server через helm: helm install nfs-server stable/nfs-server-provisioner

В конце установки будет выдан пример создания PVC для этого сервера.

## Задание 1: подключить для тестового конфига общую папку
В stage окружении часто возникает необходимость отдавать статику бекенда сразу фронтом. Проще всего сделать это через общую папку. Требования:
* в поде подключена общая папка между контейнерами (например, /static);
* после записи чего-либо в контейнере с беком файлы можно получить из контейнера с фронтом.

## Задание 2: подключить общую папку для прода
Поработав на stage, доработки нужно отправить на прод. В продуктиве у нас контейнеры крутятся в разных подах, поэтому потребуется PV и связь через PVC. Сам PV должен быть связан с NFS сервером. Требования:
* все бекенды подключаются к одному PV в режиме ReadWriteMany;
* фронтенды тоже подключаются к этому же PV с таким же режимом;
* файлы, созданные бекендом, должны быть доступны фронту.

___
## Выполнение ДЗ:

### Подготовка:

Установка Help согласно инструкции:

        curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

        helm repo add stable https://charts.helm.sh/stable && helm repo update

Установка nfs-provisioner командой `helm install nfs-server stable/nfs-server-provisioner`:

        helm install nfs-server stable/nfs-server-provisioner

        NAME: nfs-server
        LAST DEPLOYED: Tue Feb  8 15:27:30 2022
        NAMESPACE: default
        STATUS: deployed
        REVISION: 1
        TEST SUITE: None
        NOTES:
        The NFS Provisioner service has now been installed.

        A storage class named 'nfs' has now been created
        and is available to provision dynamic volumes.

        You can use this storageclass by creating a `PersistentVolumeClaim` with the 
        correct storageClassName attribute. For example:

            ---
            kind: PersistentVolumeClaim
            apiVersion: v1
            metadata:
            name: test-dynamic-volume-claim
            spec:
            storageClassName: "nfs"
            accessModes:
                - ReadWriteOnce
            resources:
                requests:
                storage: 100Mi

Проверим storageclass командой `kubectl get sc`:

        kubectl get sc
        NAME   PROVISIONER                                       RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE  
        nfs    cluster.local/nfs-server-nfs-server-provisioner   Delete          Immediate           true                   3m11s

___
## Задание 1: подключить для тестового конфига общую папку

### 1.1 Обновим из предыдущего задания манифест для `TestDev` среды, добавив в него `Volume` с общей папкой `/static`:

В секции `spec` добавим:

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
        volumeMounts:
        - mountPath: "/static"
          name: test-volume
      - image: alexdies/backend
        imagePullPolicy: IfNotPresent
        name: backend
        ports:
        - containerPort: 9000
        env:
          - name: DATABASE_URL
            value: postgres://postgres:postgres@postgres:5432/news
        volumeMounts:
        - mountPath: "/static"
          name: test-volume
      volumes:
        - name: test-volume
          emptyDir: {}

[Манифест для Фронтенда + Бэкенда с общим volume](TestDev/back-front.yaml)

### 1.2 Запускаем обновленный манифест и проверяем поды:


        kubectl apply -f TestDev/

        service/frontend-backend created
        deployment.apps/frontend-backend created
        service/postgres created
        statefulset.apps/postgres created


        kubectl get pods

        NAME                                READY   STATUS    RESTARTS      AGE
        frontend-backend-6ddb88d955-p6tgq   2/2     Running   0             56s
        multitool-55974d5464-5wpn8          1/1     Running   1 (64m ago)   2d23h
        postgres-0                          1/1     Running   0             3m47s

### 1.3 Проверяем общую папку `/static` между контейнерами:

Подаем команду из `backend`: `kubectl exec frontend-backend-79cd554969-rxhz9 -c backend -- ls -la /static`

        kubectl exec frontend-backend-79cd554969-rxhz9 -c backend -- ls -la /static
        total 8
        drwxrwxrwx 2 root root 4096 Feb  8 11:49 .
        drwxr-xr-x 1 root root 4096 Feb  8 11:49 ..

Том `/static` присутсвует, попробуем что-то записать в него из `backend`:

        kubectl exec frontend-backend-79cd554969-rxhz9 -c backend -- sh -c "echo 'test123' > /static/test.txt"

        kubectl exec frontend-backend-79cd554969-rxhz9 -c backend -- cat /static/test.txt
        test123

Проверим общую папку `/static` во `frontend` контейнере и её содержимое:

        kubectl exec frontend-backend-79cd554969-rxhz9 -c frontend -- ls -la /s
        tatic
        total 12
        drwxrwxrwx 2 root root 4096 Feb  8 12:18 .
        drwxr-xr-x 1 root root 4096 Feb  8 11:49 ..
        -rw-r--r-- 1 root root    8 Feb  8 12:18 test.txt

        kubectl exec frontend-backend-79cd554969-rxhz9 -c frontend -- cat /static/test.txt
        test123

По итогу - файлы между контейнерами общие, все работает!
___
## Задание 2: подключить общую папку для прода

### 2.1 Редактируем предыдущие манифесты из `Prod` для `backend` и `frontend`:

Добавляем в `spec` информацию о `volumes` и в `backend` и в `frontend`:

        volumeMounts:
        - mountPath: "/static"
          name: test-volume

        volumes:
          - name: test-volume
            persistentVolumeClaim:
                claimName: test-dynamic-volume-claim

[Манифест для frontend](Prod/front.yaml)

[Манифест для backend](Prod/back.yaml)

2.2 Далее необходимо создать манифест для `PersistentVolumeClaim`:

        kind: PersistentVolumeClaim
        apiVersion: v1
        metadata:
            name: test-dynamic-volume-claim
        spec:
            storageClassName: "nfs"
            accessModes:
            - ReadWriteMany
            resources:
                requests:
                    storage: 100Mi

Указываем `storageClassName: "nfs"` для создания динамически PV через `provisioner nfs`

[Манифест для PVC](Prod/pvc.yaml)

### 2.3  Развертывание манифестов:

Выполним команду `kubectl apply -f Prod/ `

        deployment.apps/backend unchanged
        service/postgres unchanged
        statefulset.apps/postgres configured
        service/frontend unchanged
        deployment.apps/frontend created
        persistentvolumeclaim/test-dynamic-volume-claim unchanged

Проверим запущенные поды:

        kubectl get pods

        NAME                                  READY   STATUS              RESTARTS       AGE
        backend-59f97ccdff-ckk45              0/1     ContainerCreating   0              3m30s
        frontend-cb9bff95f-bmpnw              0/1     ContainerCreating   0              2m50s
        multitool-55974d5464-5wpn8            1/1     Running             1 (145m ago)   3d1h
        nfs-server-nfs-server-provisioner-0   1/1     Running             0              32m
        postgres-0                            1/1     Running             0              6m29s

Поды не запущены, находятся в состоянии создания.

Проверим `PV`:

        kubectl get persistentvolume
        NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                               STORAGECLASS   REASON   AGE
        pvc-b3af2832-5d96-4ad5-a365-4e7bd7f25280   100Mi      RWX            Delete           Bound    default/test-dynamic-volume-claim   nfs                     7m27s

PV запущен и работает.

Проверим `PVC`:

        kubectl get pvc

        NAME                        STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
        test-dynamic-volume-claim   Bound    pvc-b3af2832-5d96-4ad5-a365-4e7bd7f25280   100Mi      RWX            nfs            9m20s

PVC также запущен и работает.

Проверим `logs` подов:

        kubectl logs backend-59f97ccdff-ckk45 
        Error from server (BadRequest): container "backend" in pod "backend-59f97ccdff-ckk45" is waiting to start: ContainerCreating

Лог выдает ошибку

Проверим `describe` пода:

Видим ошибку:

        Mounting command: mount
        Mounting arguments: -t nfs -o vers=3 10.233.44.226:/export/pvc-b3af2832-5d96-4ad5-a365-4e7bd7f25280 /var/lib/kubelet/pods/03d48f7b-29b6-4926-a334-5d0b127c461d/volumes/kubernetes.io~nfs/pvc-b3af2832-5d96-4ad5-a365-4e7bd7f25280
        Output: mount: /var/lib/kubelet/pods/03d48f7b-29b6-4926-a334-5d0b127c461d/volumes/kubernetes.io~nfs/pvc-b3af2832-5d96-4ad5-a365-4e7bd7f25280: bad option; for several filesystems (e.g. nfs, cifs) you might need a /sbin/mount.<type> helper program.
        Warning  FailedMount  47s (x3 over 7m34s)  kubelet  Unable to attach or mount volumes: unmounted volumes=[test-volume], unattached volumes=[test-volume kube-api-access-bqppd]: timed out waiting for the condition

Решение - необходимо установить `nfs-common` на всех нодах (`sudo apt install nfs-common`)

После установки проверим ещё раз работу подов:

        kubectl get pods

        NAME                                  READY   STATUS    RESTARTS       AGE
        backend-59f97ccdff-ckk45              1/1     Running   0              15m
        frontend-cb9bff95f-bmpnw              1/1     Running   0              14m
        multitool-55974d5464-5wpn8            1/1     Running   1 (156m ago)   3d1h
        nfs-server-nfs-server-provisioner-0   1/1     Running   0              44m
        postgres-0                            1/1     Running   0              18m

Поды запущены, всё работает!

### 2.4. Проверим передачу данных между подами через общую папку `/static`:

Проверим досутпность общей папки `/static` на `backend`:

        kubectl exec backend-59f97ccdff-ckk45 -- ls -la /static
        total 8
        drwxrwsrwx 2 root root 4096 Feb  8 12:53 .
        drwxr-xr-x 1 root root 4096 Feb  8 13:10 ..

Создадим файл на поде `backend`:

        kubectl exec backend-59f97ccdff-ckk45 -- sh -c "echo 'test123' > /static/test.txt"

        kubectl exec backend-59f97ccdff-ckk45 -- cat /static/test.txt
        test123

Проверим файл в общей папке `/static` на другом поде `frontend`:

        kubectl exec frontend-cb9bff95f-bmpnw -- ls -la /static
        total 12
        drwxrwsrwx 2 root root 4096 Feb  8 13:14 .
        drwxr-xr-x 1 root root 4096 Feb  8 13:11 ..
        -rw-r--r-- 1 root root    8 Feb  8 13:14 test.txt

Проверим содержимое файла из общей папки `/static` на поде `frontend`:

        kubectl exec frontend-cb9bff95f-bmpnw -- cat /static/test.txt
        test123

По итогу - всё работает, общая папка между подами доступна, файлы читаются. Создана через PVC и динамическое создание PV через провизора nfs.