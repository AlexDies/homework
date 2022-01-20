# Домашнее задание к занятию "12.2 Команды для работы с Kubernetes"
Кластер — это сложная система, с которой крайне редко работает один человек. Квалифицированный devops умеет наладить работу всей команды, занимающейся каким-либо сервисом.
После знакомства с кластером вас попросили выдать доступ нескольким разработчикам. Помимо этого требуется служебный аккаунт для просмотра логов.

## Задание 1: Запуск пода из образа в деплойменте
Для начала следует разобраться с прямым запуском приложений из консоли. Такой подход поможет быстро развернуть инструменты отладки в кластере. Требуется запустить деплоймент на основе образа из hello world уже через deployment. Сразу стоит запустить 2 копии приложения (replicas=2). 

Требования:
 * пример из hello world запущен в качестве deployment
 * количество реплик в deployment установлено в 2
 * наличие deployment можно проверить командой kubectl get deployment
 * наличие подов можно проверить командой kubectl get pods


## Задание 2: Просмотр логов для разработки
Разработчикам крайне важно получать обратную связь от штатно работающего приложения и, еще важнее, об ошибках в его работе. 
Требуется создать пользователя и выдать ему доступ на чтение конфигурации и логов подов в app-namespace.

Требования: 
 * создан новый токен доступа для пользователя
 * пользователь прописан в локальный конфиг (~/.kube/config, блок users)
 * пользователь может просматривать логи подов и их конфигурацию (kubectl logs pod <pod_id>, kubectl describe pod <pod_id>)


## Задание 3: Изменение количества реплик 
Поработав с приложением, вы получили запрос на увеличение количества реплик приложения для нагрузки. Необходимо изменить запущенный deployment, увеличив количество реплик до 5. Посмотрите статус запущенных подов после увеличения реплик. 

Требования:
 * в deployment из задания 1 изменено количество реплик на 5
 * проверить что все поды перешли в статус running (kubectl get pods)

___
## Выполнение ДЗ:

## Задание 1: Запуск пода из образа в деплойменте
Требования:
 * пример из hello world запущен в качестве deployment
 * количество реплик в deployment установлено в 2
 * наличие deployment можно проверить командой kubectl get deployment
 * наличие подов можно проверить командой kubectl get pods

1.1 Создаем `deployment` приложения `hello-node` на двух репликах командой `kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4 --replicas=2`:

    [root@minikube alexd]# kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4 --replicas=2   
    deployment.apps/hello-node created

Проверяем созданный `deployment` командой `kubectl get deployments`:

    [root@minikube alexd]# kubectl get deployments
    NAME         READY   UP-TO-DATE   AVAILABLE   AGE
    hello-node   2/2     2            2           6m1s

Проверяем количество подов командой `kubectl get pods`:

    [root@minikube alexd]# kubectl get pods
    NAME                          READY   STATUS    RESTARTS   AGE
    hello-node-7567d9fdc9-lmstv   1/1     Running   0          6m41s
    hello-node-7567d9fdc9-qv6nt   1/1     Running   0          6m41s

1.2 Запускаем `service` командой `kubectl expose deployment hello-node --type=NodePort --port=8080`:

    [root@minikube alexd]# kubectl expose deployment hello-node --type=NodePort --port=8080
    service/hello-node exposed

Проверяем созданный сервис командой `kubectl get services`:

    [root@minikube alexd]# kubectl get services
    NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
    hello-node   NodePort    10.108.254.117   <none>        8080:31167/TCP   3m10s
    kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP          4d1h

Проверяем запущенный сервис командой `minikube service hello-node`:

    [root@minikube alexd]# minikube service hello-node
    |-----------|------------|-------------|--------------------------|
    | NAMESPACE |    NAME    | TARGET PORT |           URL            |
    |-----------|------------|-------------|--------------------------|
    | default   | hello-node |        8080 | http://10.128.0.29:31167 |
    |-----------|------------|-------------|--------------------------|

**Количество реплик подов в `deployment` по итогу стало равным 2**
___
## Задание 2: Просмотр логов для разработки

2.1 Пересоздаем кластер с новым IP полученным от YC: `minikube start --apiserver-ips=51.250.10.21 --vm-driver=none`

2.2 Создаем новый `Namespace` для нового пользователя с названием `app-namespace`:

    [root@minikube alexd]# kubectl create namespace app-namespace
    namespace/app-namespace created

2.3 Создаем новый `serviceaccount` с именем `testuser` и привязкой к `app-namespace`:

    [root@minikube alexd]# kubectl -n app-namespace create serviceaccount testuser
    serviceaccount/testuser created

2.4 Экспортируем `token` созданного пользователя `testuser` и расшифровываем его из `base64`:

    [root@minikube alexd]# export TOKENNAME=$(kubectl -n app-namespace get serviceaccount/testuser -o jsonpath='{.secrets[0].name}')

    [root@minikube alexd]# export TOKEN=$(kubectl -n app-namespace get secret $TOKENNAME -o jsonpath='{.data.token}' | base64 --decode)

    [root@minikube alexd]# echo $TOKEN
    eyJhbGciOiJSUzI1NiIsImtpZCI6Ik5MalplR2pqQ1VLb2w0Znl6b25rMm1xRHlaRUVlS2JlRGF4Vl9vMXpHUjgifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJhcHAtbmFtZXNwYWNlIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6InRlc3R1c2VyLXRva2VuLWNobWpxIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6InRlc3R1c2VyIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiYjYxMWU0MDYtZTMwYi00MTlkLThlNDEtOWU3OTIwNzIwMzRkIiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OmFwcC1uYW1lc3BhY2U6dGVzdHVzZXIifQ.rWKRUMe5KHkPUkLm5Yg-XDBF6DcOPQspyAfno0-3Kb3qfctYQiyz87Yc9xGTNHqIKRF1BbqFLKoEC_8yykElFxXvkPLg8Du4s3M5rwRe-tijQp8aJ-biHYRQcrFRB_MFtR0kewkdk16GQUDMzLxa64hYnaG-DTkELZXij_HVHB2qM5eDdgR7_gHWZigtwFJ8IJg85hvizNrW9LTGy2BhrhtqKannVP32QSfqK5-irDjOJoTH_DyAQCUl6S-1ftFockOySCx4qip7c6uVHnjWhOmuglIMlRgxML4cS1mxwkKNABcF9LoW6kWWMGrUyAXhbgY5ltEQcnXvB5lFQRE2Xw 

2.5 Проверяем доступность к кластеру с помощью `curl` и данного токена:


[root@minikube alexd]# curl -k -H "Authorization: Bearer $TOKEN" -X GET "https://51.250.10.21:8443/api/v1/nodes"
{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {

  },
  "status": "Failure",
  "message": "nodes is forbidden: User \"system:serviceaccount:app-namespace:testuser\" cannot list resource \"nodes\" in API group \"\" at the cluster scope",
  "reason": "Forbidden",
  "details": {
    "kind": "nodes"
  },
  "code": 403

Доступ с `token` есть, но данный аккаунт не является `clusterrole` и поэтому выдает ошибку.

2.6 Создаем новую `Role` для нового пользователя с ограничениями только на просмотр логов и конфигурацию подов (`kubectl logs pod <pod_id>, kubectl describe pod <pod_id>`) :

Содержание файла `testuser-role.yml`:
    kind: Role
    apiVersion: rbac.authorization.k8s.io/v1
    metadata:
      namespace: app-namespace
      name: test-user-role
    rules:
    - apiGroups: [""]
      resources: ["pods/log", "pod/describe"]
      verbs: ["get"]

Применение: 

    [root@minikube alexd]# kubectl -n app-namespace apply -f testuser-role.yml 
    role.rbac.authorization.k8s.io/test-user-role created

2.7 Привязываем через `role-binding` созданную `role test-user-role` для пользователя `testuser`:

Содержание файла `role-binding-testuser.yml`:

    apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
      name: role-binding-testuser
    subjects:
    - kind: User
      name: testuser
      apiGroup: rbac.authorization.k8s.io
    roleRef:
      kind: Role
      name: test-user-role
      apiGroup: rbac.authorization.k8s.io

Применение: 

    [root@minikube alexd]# kubectl -n app-namespace apply -f role-binding-testuser.yml 
    rolebinding.rbac.authorization.k8s.io/role-binding-testuser created

    [root@minikube alexd]# kubectl -n app-namespace get rolebindings.rbac.authorization.k8s.io role-binding-testuser -o wide
    NAME                    ROLE                  AGE    USERS      GROUPS   SERVICEACCOUNTS
    role-binding-testuser   Role/test-user-role   2m5s   testuser

2.8 Добавляем созданный `serviceaccount` `testuser` в `kubeconfig` с помощью команды `set-credentials`:

    [root@minikube alexd]# kubectl -n app-namespace config set-credentials testuser --token=$TOKEN
    User "testuser" set.

2.9 Переключаем текущий `context` на созданного пользователя `testuser`:

    [root@minikube alexd]# kubectl config set-context test1 --cluster minikube --user testuser --namespace app-namespace


    [root@minikube alexd]# kubectl config use-context test1 
    Switched to context "test1".

2.10 Проверяем содержание файла `kubeconfig` по пути `~/.kube/config`:

apiVersion: v1
clusters:
- cluster:
    certificate-authority: /root/.minikube/ca.crt
    extensions:
    - extension:
        last-update: Thu, 20 Jan 2022 16:53:29 UTC
        provider: minikube.sigs.k8s.io
        version: v1.24.0
      name: cluster_info
    server: https://10.128.0.29:8443
  name: minikube
contexts:
- context:
    cluster: minikube
    extensions:
    - extension:
        last-update: Thu, 20 Jan 2022 16:53:29 UTC
        provider: minikube.sigs.k8s.io
        version: v1.24.0
      name: context_info
    namespace: default
    user: testuser
  name: minikube
current-context: minikube
kind: Config
preferences: {}
users:
- name: minikube
  user:
    client-certificate: /root/.minikube/profiles/minikube/client.crt
    client-key: /root/.minikube/profiles/minikube/client.key
- name: testuser
  user:
    token: eyJhbGciOiJSUzI1NiIsImtpZCI6Ik5MalplR2pqQ1VLb2w0Znl6b25rMm1xRHlaRUVlS2JlRGF4Vl9vMXpHUjgifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJhcHAtbmFtZXNwYWNlIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6InRlc3R1c2VyLXRva2VuLWNobWpxIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6InRlc3R1c2VyIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiYjYxMWU0MDYtZTMwYi00MTlkLThlNDEtOWU3OTIwNzIwMzRkIiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OmFwcC1uYW1lc3BhY2U6dGVzdHVzZXIifQ.rWKRUMe5KHkPUkLm5Yg-XDBF6DcOPQspyAfno0-3Kb3qfctYQiyz87Yc9xGTNHqIKRF1BbqFLKoEC_8yykElFxXvkPLg8Du4s3M5rwRe-tijQp8aJ-biHYRQcrFRB_MFtR0kewkdk16GQUDMzLxa64hYnaG-DTkELZXij_HVHB2qM5eDdgR7_gHWZigtwFJ8IJg85hvizNrW9LTGy2BhrhtqKannVP32QSfqK5-irDjOJoTH_DyAQCUl6S-1ftFockOySCx4qip7c6uVHnjWhOmuglIMlRgxML4cS1mxwkKNABcF9LoW6kWWMGrUyAXhbgY5ltEQcnXvB5lFQRE2Xw




apiVersion: v1
clusters:
- cluster:
    certificate-authority: /home/testuser/.kube/ca.crt
    extensions:
    - extension:
        last-update: Thu, 20 Jan 2022 16:53:29 UTC
        provider: minikube.sigs.k8s.io
        version: v1.24.0
      name: cluster_info
    server: https://10.128.0.29:8443
  name: minikube
contexts:
- context:
    cluster: minikube
    extensions:
    - extension:
        last-update: Thu, 20 Jan 2022 16:53:29 UTC
        provider: minikube.sigs.k8s.io
        version: v1.24.0
      name: context_info
    namespace: default
    user: testuser
  name: minikube
- context:
    cluster: minikube
    namespace: app-namespace
    user: testuser
  name: test1
current-context: test1
kind: Config
preferences: {}
users:
#- name: minikube
#  user:
#    client-certificate: /root/.minikube/profiles/minikube/client.crt
#    client-key: /root/.minikube/profiles/minikube/client.key
- name: testuser
  user:
    token: eyJhbGciOiJSUzI1NiIsImtpZCI6Ik5MalplR2pqQ1VLb2w0Znl6b25rMm1xRHlaRUVlS2JlRGF4Vl9vMXpHUjgifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJhcHAtbmFtZXNwYWNlIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6InRlc3R1c2VyLXRva2VuLWNobWpxIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6InRlc3R1c2VyIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiYjYxMWU0MDYtZTMwYi00MTlkLThlNDEtOWU3OTIwNzIwMzRkIiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OmFwcC1uYW1lc3BhY2U6dGVzdHVzZXIifQ.rWKRUMe5KHkPUkLm5Yg-XDBF6DcOPQspyAfno0-3Kb3qfctYQiyz87Yc9xGTNHqIKRF1BbqFLKoEC_8yykElFxXvkPLg8Du4s3M5rwRe-tijQp8aJ-biHYRQcrFRB_MFtR0kewkdk16GQUDMzLxa64hYnaG-DTkELZXij_HVHB2qM5eDdgR7_gHWZigtwFJ8IJg85hvizNrW9LTGy2BhrhtqKannVP32QSfqK5-irDjOJoTH_DyAQCUl6S-1ftFockOySCx4qip7c6uVHnjWhOmuglIMlRgxML4cS1mxwkKNABcF9LoW6kWWMGrUyAXhbgY5ltEQcnXvB5lFQRE2Xw


2.11 Копируем сертифкат `ca.crt` из `/root/.minikube/` для нового пользователя `testuser`:

    [root@minikube .kube]# cp /root/.minikube/ca.crt /home/testuser/.kube/

2.12 Копируем содержание `kubeconfig` `~/.kube/config` для нового пользователя `testuser` по пути `/home/testuser/.kube/config`:



2.13 Проверяем доступ от пользователя `testuser` на команды `kubectl logs pod <pod_id>, kubectl describe pod <pod_id>`:




https://10.128.0.29:8443



___
## Задание 3: Изменение количества реплик

3.1 Масштабируем ресурсы `deployment` командой `kubectl scale --replicas=5 deployment hello-node`:

    [root@minikube alexd]# kubectl scale --replicas=5 deployment hello-node
    deployment.apps/hello-node scaled

3.2 Проверяем их количество командой `kubectl get deployments.apps`:

    [root@minikube alexd]# kubectl get deployments.apps 
    NAME         READY   UP-TO-DATE   AVAILABLE   AGE
    hello-node   5/5     5            5           22m

3.3 Проверяем количество подов и их статус командой `kubectl get pods`: 

    [root@minikube alexd]# kubectl get pods
    NAME                          READY   STATUS    RESTARTS   AGE
    hello-node-7567d9fdc9-84phq   1/1     Running   0          5m9s
    hello-node-7567d9fdc9-88dk4   1/1     Running   0          5m9s
    hello-node-7567d9fdc9-kx9j2   1/1     Running   0          5m9s
    hello-node-7567d9fdc9-mq9g4   1/1     Running   0          5m9s
    hello-node-7567d9fdc9-t5vqc   1/1     Running   0          5m9s

**По итогу, количество реплик подов увеличилось до 5 шт. То есть с помощью `scale` мы можем масштабировать (уменешать или увеличивать количество реплик подов с приложением)**