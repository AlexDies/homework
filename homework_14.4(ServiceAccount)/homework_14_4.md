# Домашнее задание к занятию "14.4 Сервис-аккаунты"

## Задача 1: Работа с сервис-аккаунтами через утилиту kubectl в установленном minikube

Выполните приведённые команды в консоли. Получите вывод команд. Сохраните
задачу 1 как справочный материал.

### Как создать сервис-аккаунт?

```
kubectl create serviceaccount netology
```

### Как просмотреть список сервис-акаунтов?

```
kubectl get serviceaccounts
kubectl get serviceaccount
```

### Как получить информацию в формате YAML и/или JSON?

```
kubectl get serviceaccount netology -o yaml
kubectl get serviceaccount default -o json
```

### Как выгрузить сервис-акаунты и сохранить его в файл?

```
kubectl get serviceaccounts -o json > serviceaccounts.json
kubectl get serviceaccount netology -o yaml > netology.yml
```

### Как удалить сервис-акаунт?

```
kubectl delete serviceaccount netology
```

### Как загрузить сервис-акаунт из файла?

```
kubectl apply -f netology.yml
```

## Задача 2 (*): Работа с сервис-акаунтами внутри модуля

Выбрать любимый образ контейнера, подключить сервис-акаунты и проверить
доступность API Kubernetes

```
kubectl run -i --tty fedora --image=fedora --restart=Never -- sh
```

Просмотреть переменные среды

```
env | grep KUBE
```

Получить значения переменных

```
K8S=https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT
SADIR=/var/run/secrets/kubernetes.io/serviceaccount
TOKEN=$(cat $SADIR/token)
CACERT=$SADIR/ca.crt
NAMESPACE=$(cat $SADIR/namespace)
```

Подключаемся к API

```
curl -H "Authorization: Bearer $TOKEN" --cacert $CACERT $K8S/api/v1/
```

В случае с minikube может быть другой адрес и порт, который можно взять здесь

```
cat ~/.kube/config
```

или здесь

```
kubectl cluster-info
```
___
### Выполнение ДЗ:

#### Задача 1: Работа с сервис-аккаунтами через утилиту `kubectl`

##### 1.1 Создание сервис-аккаунта:
```
kubectl create serviceaccount netologyaccount
serviceaccount/netologyaccount created
```
##### 1.2 Просмотр нового сервис-аккаунта:
```
kubectl get serviceaccounts 
NAME                                SECRETS   AGE
default                             1         80d
netologyaccount                     1         28s
nfs-server-nfs-server-provisioner   1         70d
```
##### 1.3 Получение информации о сервис-аккаунте в файл `json` и `yaml`:
```
kubectl get serviceaccounts netologyaccount -o yaml 
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: "2022-04-19T12:44:52Z"
  name: netologyaccount
  namespace: default
  resourceVersion: "412651"
  uid: d3f40d57-8af9-40e5-87bc-534b14472316
secrets:
- name: netologyaccount-token-dvnkk



kubectl get serviceaccounts default -o json
{
    "apiVersion": "v1",
    "kind": "ServiceAccount",
    "metadata": {
        "creationTimestamp": "2022-01-29T08:07:26Z",
        "name": "default",
        "namespace": "default",
        "resourceVersion": "418",
        "uid": "b6e07ebb-9cdb-4c13-a9bc-e0843745fece"
    },
    "secrets": [
        {
            "name": "default-token-vjk9n"
        }
    ]
}
```
##### 1.4 Выгрузка сервис-аккаунта в файл `json` и `yaml`:
```
kubectl get serviceaccounts -o json > serviceaccounts.json
kubectl get serviceaccounts netologyaccount -o yaml > netology.yaml
```
##### 1.5 Удаление сервис-аккаунта:
```
kubectl delete serviceaccounts netologyaccount 
serviceaccount "netologyaccount" deleted
```
##### 1.6 Загрузка сервис-аккаунта из файла `yaml`:
```
kubectl apply -f netology.yaml 
serviceaccount/netologyaccount created

kubectl get serviceaccounts netologyaccount 
NAME              SECRETS   AGE
netologyaccount   2         11s
```
---
#### Задача 2: Работа с сервис-акаунтами внутри модуля

##### 2.1 Подключение к образу Fedora:
```
kubectl run -ti fedora --image=fedora --restart=Never -- sh
```
##### 2.2 Считывание и запись значений переменных:
```
sh-5.1# env | grep KUBE
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_SERVICE_PORT=443
KUBERNETES_PORT_443_TCP=tcp://10.233.0.1:443
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_ADDR=10.233.0.1
KUBERNETES_SERVICE_HOST=10.233.0.1
KUBERNETES_PORT=tcp://10.233.0.1:443
KUBERNETES_PORT_443_TCP_PORT=443
```
Запись в переменные:
```
sh-5.1# SADIR=/var/run/secrets/kubernetes.io/serviceaccount
sh-5.1# TOKEN=$(cat $SADIR/token)
sh-5.1# CACERT=$SADIR/ca.crt
```
##### 2.3 Провека подключения к API:
```
sh-5.1# curl --cacert $CACERT -H "Authorization: Bearer $TOKEN" https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT_HTTPS/api/
{
  "kind": "APIVersions",
  "versions": [
    "v1"
  ],
  "serverAddressByClientCIDRs": [
    {
      "clientCIDR": "0.0.0.0/0",
      "serverAddress": "10.128.0.16:6443"
    }
  ]
}
```

На этом задание выполнено!

