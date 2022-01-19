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

https://kubernetes.io/docs/reference/access-authn-authz/authentication/


[root@minikube alexd]# kubectl -n app-namespace create serviceaccount testuser
serviceaccount/testuser created

[root@minikube alexd]# kubectl -n app-namespace apply -f testuser-role.yml 
role.rbac.authorization.k8s.io/test-user-role created


[root@minikube alexd]# kubectl -n app-namespace get roles.rbac.authorization.k8s.io
NAME             CREATED AT
test-user-role   2022-01-18T18:07:12Z
[root@minikube alexd]# kubectl -n app-namespace get roles.rbac.authorization.k8s.io -o yaml
apiVersion: v1
items:
- apiVersion: rbac.authorization.k8s.io/v1
  kind: Role
  metadata:
    annotations:
      kubectl.kubernetes.io/last-applied-configuration: |
        {"apiVersion":"rbac.authorization.k8s.io/v1","kind":"Role","metadata":{"annotations":{},"name":"test-user-role","namespace":"app-namespace"},"rules":[{"apiGroups":[""],"resources":["pods/log","pod/describe"],"verbs":["get"]}]}
    creationTimestamp: "2022-01-18T18:07:12Z"
    name: test-user-role
    namespace: app-namespace
    resourceVersion: "18872"
    uid: 24e22510-d3dd-4ec4-a23d-50cc1a2c1ae4
  rules:
  - apiGroups:
    - ""
    resources:
    - pods/log
    - pod/describe
    verbs:
    - get
kind: List
metadata:
  resourceVersion: ""
  selfLink: ""


[root@minikube alexd]# kubectl -n app-namespace apply -f role-binding-testuser.yml 
rolebinding.rbac.authorization.k8s.io/role-binding-testuser created


[root@minikube alexd]# kubectl -n app-namespace get rolebindings.rbac.authorization.k8s.io role-binding-testuser
NAME                    ROLE                  AGE
role-binding-testuser   Role/test-user-role   24s
[root@minikube alexd]# kubectl -n app-namespace get rolebindings.rbac.authorization.k8s.io role-binding-testuser -o yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"rbac.authorization.k8s.io/v1","kind":"RoleBinding","metadata":{"annotations":{},"name":"role-binding-testuser","namespace":"app-namespace"},"roleRef":{"apiGroup":"rbac.authorization.k8s.io","kind":"Role","name":"test-user-role"},"subjects":[{"apiGroup":"rbac.authorization.k8s.io","kind":"User","name":"testuser"}]}
  creationTimestamp: "2022-01-18T18:10:56Z"
  name: role-binding-testuser
  namespace: app-namespace
  resourceVersion: "19059"
  uid: 6b65be6b-f9ea-4b8a-8e47-ef75808a807c
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: test-user-role
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: testuser





root@minikube alexd]# kubectl get secret $(kubectl get serviceaccount testuser -o jsonpath='{.secrets[0].name}' --namespace app-namespace) -o jsonpath='{.data.token}' --namespace app-namespace | base64 -d 
eyJhbGciOiJSUzI1NiIsImtpZCI6Im9JbHF1T0xsaWlXWndlZWFHZjloNXgzdEdkRWpzbnA0cEl1NXZLRmd6MGsifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJhcHAtbmFtZXNwYWNlIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6InRlc3R1c2VyLXRva2VuLWQ4bXd6Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6InRlc3R1c2VyIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiYmRhMjIwODEtNjViZS00MWRkLWE4NzUtNDAzZjQ3MWY5MGVjIiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OmFwcC1uYW1lc3BhY2U6dGVzdHVzZXIifQ.jkwHrezj0dd3354W2wXntgpCqTOP3kNerkkoP0llthj5aW0rotYq7zT-kdDvVC8CMlC3y8et4oDEbO6S9ZR6BmLeS9qlITbHIVUtTBHw7RVtbO7m5N_QA8neZOHx9T3cXJJ3kQpvNE7bRj1BGqz9i3meCwjbvjx5Uhe-N_iJ20No2T1kf_jn7KqwMY3_-ic7WOvdWK8YCPYkyBfEs4fYKJpZAmY60E2Z1dtkEePU1r13RR67a7CGjtaV-z2yva2afC86q79Zk36spIfNCJjC_pr__OgmMXEuR9bBtHE4Vj2vYKoD92gQkD-ClwuRkd_frJuI8TKmxgk4k1GcbROFcA



eyJhbGciOiJSUzI1NiIsImtpZCI6Im9JbHF1T0xsaWlXWndlZWFHZjloNXgzdEdkRWpzbnA0cEl1NXZLRmd6MGsifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJ0ZXN0LW9uZSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJ0ZXN0LXNhLW9uZS10b2tlbi0yYzdncSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJ0ZXN0LXNhLW9uZSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjBmMGJkYTVkLWM5YjAtNGFiNS1iZGI2LTY1NzM1ZTdjNDA2ZCIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDp0ZXN0LW9uZTp0ZXN0LXNhLW9uZSJ9.HdhoGm7RJOHC5OSpNio6_monuz1RAus-tm1GrTzpgGCI6mAYITD6HO1rtxPSiIF6pvRKhPd_O4ibHlP7USPG-h4cJtlNU00VaTwggDywgD-CUUTO1lrE3CHDvtSVEtRBDMpDl0DFyF2FV1wADftu4tMZsREVe3uE2Q9wfaRpbsPkKHgBeBloKNNII5RPMzmj7G1EyAYodLRs2RbW9jAcVG4AGvN5SPvMQ-l5PwMKCNHOem3zwXwNMsjd6NL05aoaYjK5c93SEHtM4Paf_tWBzGPT4hWOex9kNTvgpa_PCAJ2mtC7llh-I7R4bLmjW3WZ-RtbjFGFBHqolMG9Nt_cCA





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