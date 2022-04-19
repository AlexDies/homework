# Домашнее задание к занятию "14.3 Карты конфигураций"

## Задача 1: Работа с картами конфигураций через утилиту kubectl в установленном minikube

Выполните приведённые команды в консоли. Получите вывод команд. Сохраните
задачу 1 как справочный материал.

### Как создать карту конфигураций?

```
kubectl create configmap nginx-config --from-file=nginx.conf
kubectl create configmap domain --from-literal=name=netology.ru
```

### Как просмотреть список карт конфигураций?

```
kubectl get configmaps
kubectl get configmap
```

### Как просмотреть карту конфигурации?

```
kubectl get configmap nginx-config
kubectl describe configmap domain
```

### Как получить информацию в формате YAML и/или JSON?

```
kubectl get configmap nginx-config -o yaml
kubectl get configmap domain -o json
```

### Как выгрузить карту конфигурации и сохранить его в файл?

```
kubectl get configmaps -o json > configmaps.json
kubectl get configmap nginx-config -o yaml > nginx-config.yml
```

### Как удалить карту конфигурации?

```
kubectl delete configmap nginx-config
```

### Как загрузить карту конфигурации из файла?

```
kubectl apply -f nginx-config.yml
```

## Задача 2 (*): Работа с картами конфигураций внутри модуля

Выбрать любимый образ контейнера, подключить карты конфигураций и проверить
их доступность как в виде переменных окружения, так и в виде примонтированного
тома

___
### Выполнение ДЗ:

#### Задача 1: Работа с картами конфигураций через утилиту kubectl в установленном minikube
##### 1.1 Создание `configmap` `nginx-config` из файла `nginx.conf` и `configmap` `domain` со статичным значением `name=netology.ru`

```
kubectl create configmap nginx-config --from-file=nginx.conf 
configmap/nginx-config created

kubectl create configmap domain --from-literal=name=netology.ru
configmap/domain created
```
##### 1.2 Просмотр списка `configmap`:
```
kubectl get configmaps 
NAME               DATA   AGE
domain             1      31s
kube-root-ca.crt   1      80d
nginx-config       1      76s
```
##### 1.3 Детальный просмотр `configmap`:
```
kubectl get configmaps nginx-config 
NAME           DATA   AGE
nginx-config   1      2m15s


kubectl describe configmaps domain 
Name:         domain
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
name:
----
netology.ru

BinaryData
====

Events:  <none>
```
##### 1.5 Просмотр `configmap` в формате yaml и json:
```
kubectl get configmaps nginx-config -o yaml 
apiVersion: v1
data:
  nginx.conf: |
    server {
        listen 80;
        server_name  netology.ru www.netology.ru;
        access_log  /var/log/nginx/domains/netology.ru-access.log  main;
        error_log   /var/log/nginx/domains/netology.ru-error.log info;
        location / {
            include proxy_params;
            proxy_pass http://10.10.10.10:8080/;
        }
    }
kind: ConfigMap
metadata:
  creationTimestamp: "2022-04-19T08:11:57Z"
  name: nginx-config
  namespace: default
  resourceVersion: "378909"
  uid: 31458cdf-cd72-40a4-b03a-e546fd4215e4



kubectl get configmaps domain -o json
{
    "apiVersion": "v1",
    "data": {
        "name": "netology.ru"
    },
    "kind": "ConfigMap",
    "metadata": {
        "creationTimestamp": "2022-04-19T08:12:42Z",
        "name": "domain",
        "namespace": "default",
        "resourceVersion": "379028",
        "uid": "5bd32d38-f2ab-43d0-82f5-8c9dff3e7a47"
    }
}
```
##### 1.6 Выгрузка `configmap` в файл:
```
kubectl get configmaps -o json > configmaps.json
kubectl get configmaps nginx-config -o yaml > nginx-config.yml
```
##### 1.7 Удаление `configmap`:
```
kubectl delete configmaps nginx-config 
configmap "nginx-config" deleted
```
##### 1.8 Загрузка `configmap` из файла:
```
kubectl apply -f nginx-config.yml 
configmap/nginx-config created

kubectl get configmaps nginx-config 
NAME           DATA   AGE
nginx-config   1      11s
```
---
#### Задача 2: Работа с картами конфигураций внутри модуля

##### 2.1 Подготовка `configmap`:

В нём будет содержаться файл конфигурации (`nginx.conf`) для `nginx` на прослушивание 8080 порта и конфигурация для отображения стандартной html-страницы(`nginx.html`). А также env-переменная (`TestEnv`).
```
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx
data:
  TestEnv: "TEST"
  nginx.html: |
    <html><head>TEST MESAGE</head>
    <body><h1>1234</h1>
    </body></html>
  nginx.conf: |
    server {
    listen       8080;
    server_name  localhost;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
     }
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
     }
    }
```
##### 2.2 Далее создадим манифест пода за основу возьмём образ `Nginx`:
```
---
apiVersion: v1
kind: Pod
metadata:
  name: netology-14.3
spec:
  containers:
  - name: nginxtest
    image: nginx:1.14.2
    imagePullPolicy: IfNotPresent
    env:
      - name: TestEnv
        valueFrom:
          configMapKeyRef:
            name: nginx
            key: TestEnv
    volumeMounts:
      - name: nginx-vol
        mountPath: /usr/share/nginx/html/
        readOnly: true
      - name: nginx-conf
        mountPath: /etc/nginx/conf.d/
  volumes:
  - name: nginx-vol
    configMap:
      name: nginx
      items:
        - key: nginx.html
          path: index.html
  - name: nginx-conf
    configMap:
      name: nginx
      items:
        - key: nginx.conf
          path: default.conf
```
Итоговый манифест:
[Манифест Pod Configmap](myapp-pod.yml)

##### 2.3 Проверим работу манифеста и изменение параметров переданных через `configmap`:

Проверим передачу переменной:
```
root@netology-14:/# env | grep TEST
TestEnv=TEST
```
Далее проверим, что конфиг передался:
```
root@netology-14:/# cat /etc/nginx/conf.d/default.conf
server {
listen       8080;
server_name  localhost;

location / {
    root   /usr/share/nginx/html;
    index  index.html index.htm;
 }
error_page   500 502 503 504  /50x.html;
location = /50x.html {
    root   /usr/share/nginx/html;
 }
}
```
Проверим отоброжение index.html. Настроим port-forward и проверим отображение в WEB.
```
$ kubectl port-forward netology-14.3 8080:8080
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
Handling connection for 8080
```
[WEB](testweb.JPG)

Всё отображается верно!
