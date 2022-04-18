# Домашнее задание к занятию "14.2 Синхронизация секретов с внешними сервисами. Vault"

## Задача 1: Работа с модулем Vault

Запустить модуль Vault конфигураций через утилиту kubectl в установленном minikube

```
kubectl apply -f 14.2/vault-pod.yml
```

Получить значение внутреннего IP пода

```
kubectl get pod 14.2-netology-vault -o json | jq -c '.status.podIPs'
```

Примечание: jq - утилита для работы с JSON в командной строке

Запустить второй модуль для использования в качестве клиента

```
kubectl run -i --tty fedora --image=fedora --restart=Never -- sh
```

Установить дополнительные пакеты

```
dnf -y install pip
pip install hvac
```

Запустить интепретатор Python и выполнить следующий код, предварительно
поменяв IP и токен

```
import hvac
client = hvac.Client(
    url='http://10.10.133.71:8200',
    token='aiphohTaa0eeHei'
)
client.is_authenticated()

# Пишем секрет
client.secrets.kv.v2.create_or_update_secret(
    path='hvac',
    secret=dict(netology='Big secret!!!'),
)

# Читаем секрет
client.secrets.kv.v2.read_secret_version(
    path='hvac',
)
```

## Задача 2 (*): Работа с секретами внутри модуля

* На основе образа fedora создать модуль;
* Создать секрет, в котором будет указан токен;
* Подключить секрет к модулю;
* Запустить модуль и проверить доступность сервиса Vault.

___
## Выполнение ДЗ:

P/S. Решил сразу объединить оба задания в одно целиком.
## Задача 1 и Задача 2:

##### 1. Подготовим dockerfile с нашим модифицированным приложением. Приложение будет записывать по tokenу в `Vault` значение переменной `netology`. Далее сразу же считывать её значение и выдавать пользователю на экран.
```
FROM fedora:latest
RUN dnf install -y pip
RUN pip install hvac
COPY testapp.py /
RUN chmod +x /testapp.py
ENTRYPOINT [ "/testapp.py" ]
```
[Dockerfile](dockerfile)

##### 2. Подготовим манифест для установки `Vault`:

Будем использовать `Deployment` для `Vault`, указав переменные:

```
VAULT_DEV_ROOT_TOKEN_ID   value: "aiphohTaa0eeHei"
VAULT_DEV_LISTEN_ADDRESS  value: 0.0.0.0:8200
```
Вид Deployment следующий:

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vault
spec:
  selector:
    matchLabels:
      app: vault
  replicas: 1
  template:
    metadata:
      labels:
        app: vault
    spec:
      terminationGracePeriodSeconds: 3
      containers:
        - name: vault
          image: vault
          imagePullPolicy: IfNotPresent
          ports:
            - containerPort: 8200
              protocol: TCP
          env:
           - name: VAULT_DEV_ROOT_TOKEN_ID
             value: "aiphohTaa0eeHei"
           - name: VAULT_DEV_LISTEN_ADDRESS
             value: 0.0.0.0:8200
```
Далее подготовим манифест для `service`, так как к `Vault` должен быть доступ у других сервисов на порту `8200`. 
```
---
apiVersion: v1
kind: Service
metadata:
  name: vault
spec:
  type: ClusterIP
  ports:
    - name: vault-web
      port: 8200
      targetPort: 8200
  selector:
    app: vault
```
##### 3. Подготовим манифест для установки клиента `vault-client`, на которм будет запущено наше приложение из dockerfile-образа :
```
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vault-client
spec:
  selector:
    matchLabels:
      app: vault-client
  replicas: 1
  template:
    metadata:
      labels:
        app: vault-client
    spec:
      terminationGracePeriodSeconds: 3
      containers:
      - name: vault-client
        image: alexdies/testapp2
```
##### Итоговы вид манифеста:

[Манифест Deployement](vault-pod-deployment.yml)


##### 4. Запустим наш манифест используя команду `kubectl apply -f vault-pod-deployment.yml`:
```
kubectl get all

NAME                                      READY   STATUS    RESTARTS        AGE
pod/vault-57d46bf645-dn7x7                1/1     Running   0               19m
pod/vault-client-5b98bc5c55-vqh2l         1/1     Running   2 (18m ago)     19m

NAME                                        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)
                                                                      
service/nfs-server-nfs-server-provisioner   ClusterIP   10.233.44.226   <none>        2049/TCP,2049/UDP,32803/TCP,32803/UDP,20048/TCP,20048/UDP,875/TCP,875/UDP,111/TCP,111/UDP,662/TCP,662/UDP   69d
service/vault                               ClusterIP   10.233.19.131   <none>        8200/TCP
                                                                       134m

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/vault          1/1     1            1           19m
deployment.apps/vault-client   1/1     1            1           19m

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/vault-57d46bf645          1         1         1       19m
replicaset.apps/vault-client-5b98bc5c55   1         1         1       19m
```

Под с `vault-client` запустился не сразу, а некоторое время "вываливался" с ошибкой, так как ещё не был создан vault. После перезапуска всё прошло успешно!
##### 5. Проверим, что приложение `vault-client` получает и выдает информацию из `vault`:

Перейдём в под `vault-client` и проверим, что выдается

```
kubectl exec -ti vault-client-5b98bc5c55-vqh2l -- /testapp.py
Netology
Netology
Netology
```

Информация полученная из `Vault` нашим приложением выдается успешно!