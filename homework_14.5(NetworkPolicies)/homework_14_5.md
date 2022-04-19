# Домашнее задание к занятию "14.5 SecurityContext, NetworkPolicies"

## Задача 1: Рассмотрите пример 14.5/example-security-context.yml

Создайте модуль

```
kubectl apply -f 14.5/example-security-context.yml
```

Проверьте установленные настройки внутри контейнера

```
kubectl logs security-context-demo
uid=1000 gid=3000 groups=3000
```

## Задача 2 (*): Рассмотрите пример 14.5/example-network-policy.yml

Создайте два модуля. Для первого модуля разрешите доступ к внешнему миру
и ко второму контейнеру. Для второго модуля разрешите связь только с
первым контейнером. Проверьте корректность настроек.

___
### Выполнение ДЗ:

#### Задача 1: Рассмотрите пример 14.5/example-security-context.yml
##### 1.1 Создание пода из `example-security-context.yml`:
```
kubectl apply -f example-security-context.yml 
pod/security-context-demo created
```
##### 1.2 Проверяем установленные настройки внутри пода:
```
kubectl logs security-context-demo 
uid=1000 gid=3000 groups=3000
```
---
#### Задача 2: Рассмотрите пример 14.5/example-network-policy.yml
##### 2.1 Создаем deployment на образах `hello-node` и `multitool`:
```
kubectl create deployment multitooltest --image=praqma/network-multitool:alpine-extra
deployment.apps/multitooltest created

kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4
deployment.apps/hello-node created
```
##### 2.2 Создаем `service` для данных деплоев:
```
---
apiVersion: v1
kind: Service
metadata:
  name: hello-node
spec:
  ports:
    - name: web
      port: 8080
  selector:
    app: hello-node
---
apiVersion: v1
kind: Service
metadata:
  name: multitool
spec:
  ports:
    - name: web
      port: 80
  selector:
    app: multitooltest
```
##### 2.3 Проверяем доступность из `multitooltest` в `hello-node`: 
```
kubectl exec multitooltest-786794f6-kc5ft -- curl -m1 -s http://10.233.12.148:8080                           
CLIENT VALUES:
client_address=10.233.90.77
command=GET
real path=/
query=nil
request_version=1.1
request_uri=http://10.233.12.148:8080/

SERVER VALUES:
server_version=nginx: 1.10.0 - lua: 10001

HEADERS RECEIVED:
accept=*/*
host=10.233.12.148:8080
user-agent=curl/7.79.1
BODY:
```
##### 2.4 Проверяем доступность из `hello-node` в `multitooltest`: 
```
kubectl exec hello-node-6b89d599b9-f25p6 -- curl -m1 -s http://10.233.37.225:80
Praqma Network MultiTool (with NGINX) - multitooltest-786794f6-kc5ft - 10.233.90.77
```
##### 2.5 Добавляем `NetworkPolicy`, которая ограничит доступ `hello-node` только к контейнеру `multitooltest` по 80 порту и не будет иметь доступ к другим (внешнему миру):
```
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: test-network-policy
spec:
  podSelector:
    matchLabels:
      app: hello-node
  policyTypes:
    - Egress
  egress:
    - to:
      - podSelector:
          matchLabels:
            app: multitooltest
      ports:
      - protocol: TCP
        port: 80
```
##### 2.6 Проверим доступность `hello-node` в `multitooltest` и доступность к внешнему миру, после применения нашей `NetworkPolicy`:

Доступ из `hello-node` в `multitooltest`:
```
kubectl exec hello-node-6b89d599b9-f25p6 -- curl -m1 -s http://10.233.37.225:80
Praqma Network MultiTool (with NGINX) - multitooltest-786794f6-kc5ft - 10.233.90.77
```
Доступ `multitooltest` на внешний под `10.233.34.5:9000`:
```
kubectl exec multitooltest-786794f6-kc5ft -- curl -m1 -s http://10.233.34.5:9000
{"detail":"Not Found"}
```
Доступ `hello-node` на внешний под `10.233.34.5:9000`:
```
kubectl exec hello-node-6b89d599b9-f25p6 -- curl -m1 -s http://10.233.34.5:9000
command terminated with exit code 28
```
В итоге видим, что политика для `hello-node` работает!