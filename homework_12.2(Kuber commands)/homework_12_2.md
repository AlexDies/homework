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

## Задание 2: Просмотр логов для разработки


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