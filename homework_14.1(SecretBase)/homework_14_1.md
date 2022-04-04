# Домашнее задание к занятию "14.1 Создание и использование секретов"

## Задача 1: Работа с секретами через утилиту kubectl в установленном minikube

Выполните приведённые ниже команды в консоли, получите вывод команд. Сохраните
задачу 1 как справочный материал.


## Задача 2 (*): Работа с секретами внутри модуля

Выберите любимый образ контейнера, подключите секреты и проверьте их доступность
как в виде переменных окружения, так и в виде примонтированного тома.

___
## Выполнение ДЗ:

## Задача 1: Работа с секретами через утилиту kubectl в установленном minikube

Для выполнения ДЗ используем ранее развернутый кластер kubernetes в YC.

##### 1.1) Создание секрета `test-cert`:

        alexd@DESKTOP-92FN9PG:~/14_1HW$ openssl genrsa -out cert.key 4096
        Generating RSA private key, 4096 bit long modulus (2 primes)
        ........................................++++
        .....................++++
        e is 65537 (0x010001)

        alexd@DESKTOP-92FN9PG:~/14_1HW$ openssl req -x509 -new -key cert.key -days 3650 -out cert.crt \
        > -subj "/C=RU/ST=Moscow/L=Moscow/CN=server.local"

        alexd@DESKTOP-92FN9PG:~/14_1HW$ ls
        cert.crt  cert.key

Загружаем секрет в `kubernetes` используя метод `tls`:

        alexd@DESKTOP-92FN9PG:~/14_1HW$ kubectl create secret tls test-cert --cert=cert.crt --key=cert.key 
        secret/test-cert created

##### 1.2) Просмотр созданных секретов используя команду `kubectl get secrets`:

        alexd@DESKTOP-92FN9PG:~/14_1HW$ kubectl get secrets 
        NAME                                            TYPE                                  DATA   AGE
        default-token-vjk9n                             kubernetes.io/service-account-token   3      65d       
        nfs-server-nfs-server-provisioner-token-tzx25   kubernetes.io/service-account-token   3      55d       
        sh.helm.release.v1.nfs-server.v1                helm.sh/release.v1                    1      55d       
        sh.helm.release.v1.version1.v1                  helm.sh/release.v1                    1      53d       
        sh.helm.release.v1.version1.v2                  helm.sh/release.v1                    1      53d       
        sh.helm.release.v1.version3.v1                  helm.sh/release.v1                    1      53d       
        test-cert                                       kubernetes.io/tls                     2      35s 


##### 1.3) Просмотр созданного секрета `test-cert`:

        alexd@DESKTOP-92FN9PG:~/14_1HW$ kubectl get secrets test-cert 
        NAME        TYPE                DATA   AGE
        test-cert   kubernetes.io/tls   2      11m



        alexd@DESKTOP-92FN9PG:~/14_1HW$ kubectl describe secrets test-cert 
        Name:         test-cert
        Namespace:    default
        Labels:       <none>
        Annotations:  <none>

        Type:  kubernetes.io/tls

        Data
        ====
        tls.crt:  1944 bytes
        tls.key:  3243 bytes

Как видим, секрет с сертификатом и ключом создан

##### 1.4) Проверяем вывод секрета в `YAML` и `JSON`:

        alexd@DESKTOP-92FN9PG:~/14_1HW$ kubectl get secrets test-cert -o yaml
        apiVersion: v1
        data:
        tls.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUZiVENDQTFXZ0F3SUJBZ0lVTG1laWp2TjlLbHpZbTVUNWRBeW96OC9VMHVZd0RRWUpLb1pJaHZjTkFRRUwKQlFBd1JqRU<МНОГО БУКВ>
        FTNQoxQT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
        tls.key: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlKSndJQkFBS0NBZ0VBMEVYM3YrSWh5Ry9ZaEt5YjROQUJSSGtMOTBXRktwWHBWQ2FjMHhSWTFnUVBMUVl0CjltUD<МНОГО БУКВ>
        LS1FTkQgUlNBIFBSSVZBVEUgS0VZLS0tLS0K
        kind: Secret
        metadata:
        creationTimestamp: "2022-04-04T17:02:30Z"
        name: test-cert
        namespace: default
        resourceVersion: "303001"
        uid: 35a5bd49-e15f-4008-9809-0650b2971d84
        type: kubernetes.io/tls


        alexd@DESKTOP-92FN9PG:~/14_1HW$ kubectl get secrets test-cert -o json
        {
            "apiVersion": "v1",
            "data": {
                "tls.crt": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUZiVENDQTFXZ0F3SUJBZ0lVTG1laWp2TjlLbHpZbTVUNWRBeW96OC9VMHVZd0RRWUpLb1pJaHZjTkFRRUwKQlF<МНОГО БУКВ>tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K",
                "tls.key": "LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlKSndJQkFBS0NBZ0VBMEVYM3YrSWh5Ry9ZaEt5YjROQUJSSGtMOTBXRktwWHBWQ2FjMHhSWTFnUVBMUVl<МНОГО БУКВ>xM0pPV1c1dG8rdDhkY0MzZVBrN2xybGtmdFZKNDBIZUxoUExzSkZGUDRBPT0KLS0tLS1FTkQgUlNBIFBSSVZBVEUgS0VZLS0tLS0K"
            },
            "kind": "Secret",
            "metadata": {
                "creationTimestamp": "2022-04-04T17:02:30Z",
                "name": "test-cert",
                "namespace": "default",
                "resourceVersion": "303001",
                "uid": "35a5bd49-e15f-4008-9809-0650b2971d84"
            },
            "type": "kubernetes.io/tls"
        }
##### 1.5) Проверим выгрузку секрета в файл:

Выгрузка в `JSON`:

        alexd@DESKTOP-92FN9PG:~/14_1HW$ kubectl get secrets -o json > test.json

Кусок json:

                },
                    "kind": "Secret",
                    "metadata": {
                        "creationTimestamp": "2022-04-04T17:02:30Z",
                        "name": "test-cert",
                        "namespace": "default",
                        "resourceVersion": "303001",
                        "uid": "35a5bd49-e15f-4008-9809-0650b2971d84"
                    },
                    "type": "kubernetes.io/tls"
                }
            ],
            "kind": "List",
            "metadata": {
                "resourceVersion": "",
                "selfLink": ""
            }
        }

Выгрузка в `Yaml`:

        alexd@DESKTOP-92FN9PG:~/14_1HW$ kubectl get secrets test-cert -o yaml > test-cert.yaml

Вывод:

        alexd@DESKTOP-92FN9PG:~/14_1HW$ cat test-cert.yaml 
        apiVersion: v1
        data:
        tls.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUZiVENDQTFXZ0F3SUJBZ0lVTG1laWp2TjlLbHpZbTVUNWRBeW96OC9VMHVZd0RRWUpLb1pJaHZjTkFRRUwKQlFBd1JqRUFTNQoxQT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
        tls.key: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlKSndJQkFBS0NBZ0VBMEVYM3YrSWh5Ry9ZaEt5YjROQUJSSGtMOTBXRktwWHBWQ2FjMHhSWTFnUVBMUVl0CjltUDLS1FTkQgUlNBIFBSSVZBVEUgS0VZLS0tLS0K
        kind: Secret
        metadata:
        creationTimestamp: "2022-04-04T17:02:30Z"
        name: test-cert
        namespace: default
        resourceVersion: "303001"
        uid: 35a5bd49-e15f-4008-9809-0650b2971d84
        type: kubernetes.io/tls

##### 1.6) Удаление секретов:

        alexd@DESKTOP-92FN9PG:~/14_1HW$ kubectl delete secrets test-cert 
        secret "test-cert" deleted

Проверим:

        alexd@DESKTOP-92FN9PG:~/14_1HW$ kubectl get secrets 
        NAME                                            TYPE                                  DATA   AGE
        default-token-vjk9n                             kubernetes.io/service-account-token   3      65d
        nfs-server-nfs-server-provisioner-token-tzx25   kubernetes.io/service-account-token   3      55d
        sh.helm.release.v1.nfs-server.v1                helm.sh/release.v1                    1      55d
        sh.helm.release.v1.version1.v1                  helm.sh/release.v1                    1      53d
        sh.helm.release.v1.version1.v2                  helm.sh/release.v1                    1      53d
        sh.helm.release.v1.version3.v1                  helm.sh/release.v1                    1      53d

Созданный ранее секрет удален

##### 1.7) Загрузка секрета из файла:

        alexd@DESKTOP-92FN9PG:~/14_1HW$ kubectl apply -f test-cert.yaml 
        secret/test-cert created

Проверим:

        alexd@DESKTOP-92FN9PG:~/14_1HW$ kubectl get secrets test-cert 
        NAME        TYPE                DATA   AGE
        test-cert   kubernetes.io/tls   2      25s

Секрет успешно создан!

---

## Задача 2 (*): Работа с секретами внутри модуля

Выберите любимый образ контейнера, подключите секреты и проверьте их доступность
как в виде переменных окружения, так и в виде примонтированного тома.

##### 2.1) Создадим `pod` `mypod` с переносом созданного ранее секрета `test-cert` с сертификатами в раздел `/test`:

```
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: redis
    volumeMounts:
    - name: add-crt
      mountPath: "/test"
      readOnly: true
  volumes:
  - name: add-crt
    secret:
      secretName: test-cert
```
После запуска пода проверим примонтировался ли секрет - наш сертификат и ключ:

        $ kubectl exec -ti mypod -- ls /test
        tls.crt  tls.key

Всё есть, монтирование раздела `/test` с содержимым `tls.crt`  `tls.key` из созданного секрета `test-cert`!

##### 2.2) Добавим секрет как переменную в `env` в наш под:

Создаём секрет `mysecret` в формате `generic` и присваиваем ключ-значение `password="testpassword"`:

        $ kubectl create secret generic mysecret --from-literal=password="testpassword"
        secret/mysecret created

Добавляем переменную `secret` с ключом `password` в наш под:

```
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  containers:
  - name: mypod
    image: redis
    env:
     - name: secret
       valueFrom:
         secretKeyRef:
            name: mysecret
            key: password
    volumeMounts:
    - name: add-crt
      mountPath: "/test"
      readOnly: true
  volumes:
  - name: add-crt
    secret:
      secretName: test-cert
```

Проверяем переменную `secret` в поде:

        $ kubectl exec -ti mypod -- bash -c 'echo $secret'
        testpassword

Значение переменной `secret` передалось из секрета `mysecret`!