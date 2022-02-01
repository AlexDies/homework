# Домашнее задание к занятию "12.5 Сетевые решения CNI"
После работы с Flannel появилась необходимость обеспечить безопасность для приложения. Для этого лучше всего подойдет Calico.
## Задание 1: установить в кластер CNI плагин Calico
Для проверки других сетевых решений стоит поставить отличный от Flannel плагин — например, Calico. Требования: 
* установка производится через ansible/kubespray;
* после применения следует настроить политику доступа к hello-world извне. Инструкции [kubernetes.io](https://kubernetes.io/docs/concepts/services-networking/network-policies/), [Calico](https://docs.projectcalico.org/about/about-network-policy)

## Задание 2: изучить, что запущено по умолчанию
Самый простой способ — проверить командой calicoctl get <type>. Для проверки стоит получить список нод, ipPool и profile.
Требования: 
* установить утилиту calicoctl;
* получить 3 вышеописанных типа в консоли.
___
## Выполнение ДЗ:

## Задание 1: установить в кластер CNI плагин Calico

1. Плагин `Calico `установлен по умолчанию в кластере после установке через `kuberspray`:


        alexd@DESKTOP-92FN9PG:/mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook$ 
        
        kubectl get pods -A

        NAMESPACE     NAME                                       READY   STATUS    RESTARTS      AGE
        kube-system   calico-kube-controllers-7c4d5b7bf4-cp4h6   1/1     Running   5 (72m ago)   98m
        kube-system   calico-node-2w7gv                          1/1     Running   0             100m
        kube-system   calico-node-bpnms                          1/1     Running   0             100m
        kube-system   calico-node-gkgj4                          1/1     Running   0             100m
        kube-system   calico-node-qv2lg                          1/1     Running   0             100m
        kube-system   calico-node-t4z59                          1/1     Running   0             100m
        kube-system   coredns-76b4fb4578-55w9z                   1/1     Running   0             98m
        kube-system   coredns-76b4fb4578-x6pbs                   1/1     Running   0             98m
        kube-system   dns-autoscaler-7979fb6659-lr29n            1/1     Running   0             98m
        kube-system   kube-apiserver-cp1                         1/1     Running   1             101m
        kube-system   kube-controller-manager-cp1                1/1     Running   2 (97m ago)   101m
        kube-system   kube-proxy-2xdcz                           1/1     Running   0             100m
        kube-system   kube-proxy-9jcvz                           1/1     Running   0             101m
        kube-system   kube-proxy-c5z2h                           1/1     Running   0             100m
        kube-system   kube-proxy-ktg9h                           1/1     Running   0             100m
        kube-system   kube-proxy-xl6xs                           1/1     Running   0             100m
        kube-system   kube-scheduler-cp1                         1/1     Running   1             101m
        kube-system   nodelocaldns-dl9dp                         1/1     Running   0             98m
        kube-system   nodelocaldns-m42tc                         1/1     Running   0             98m
        kube-system   nodelocaldns-pdq5h                         1/1     Running   0             98m
        kube-system   nodelocaldns-q6nf9                         1/1     Running   0             98m
        kube-system   nodelocaldns-r28w5                         1/1     Running   0             98m

2. Настройка политики доступа из приложения `multitool` в `hello-node` с разными `namespace`:

**Примечание:**
Для себя решим не использовать стандарный `namespace default`, а сделать два приложения в двух разных `namespace` и попрактиковаться.

- 2.1 Создадим новый `namespace` для приложения `hello-node` - `app`

        kubectl create namespace app
        namespace/app created

- 2.2 Задеплоим приложение `hello-node` в `namespace app`: 

        kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4 --namespace=app
        deployment.apps/hello-node created

- 2.3 Создадим ещё один `namespace` для приложения `multitool` - `multitool`

        kubectl create namespace multitool
        namespace/multitool created

- 2.4 Задеплоим приложение `multitool` в `namespace multitool`:

        kubectl create deployment multitool --image=praqma/network-multitool:alpine-extra --namespace=multitool
        deployment.apps/multitool created

3. Проверка текущих политик в `namespace app`:

- 3.1 С помощью команды `kubectl -n app get networkpolicies` посмотрим текущие политики:

        kubectl -n app get networkpolicies 
        No resources found in app namespace.

В новом созданном `Namespace `политики отсутсвуют. 

- 3.2 Проверим доступность пода `hello-node` из пода `multitool`:

        kubectl -n multitool exec multitool-55974d5464-ttw7t -- curl 10.233.90.45:8080

        % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                        Dload  Upload   Total   Spent    Left  Speed        
        0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0CLIENT 
        VALUES:
        100   295    0   295    0     0   161k      0 --:--:-- --:--:-- --:--:--  288k       
        client_address=10.233.90.46
        command=GET
        real path=/
        query=nil
        request_version=1.1
        request_uri=http://10.233.90.45:8080/

        SERVER VALUES:
        server_version=nginx: 1.10.0 - lua: 10001

        HEADERS RECEIVED:
        accept=*/*
        host=10.233.90.45:8080
        user-agent=curl/7.79.1
        BODY:
        -no body in request-

##### Доступ есть, так как нет политики запрета по умолчанию для нового namespace.

- 3.4 Создадим `default` политику - запрещать всё входящее в `namespace app` в формате:

        apiVersion: networking.k8s.io/v1
        kind: NetworkPolicy
        metadata:
        name: default-deny-ingress
        namespace: app
        spec:
        podSelector: {}
        policyTypes:
            - Ingress

        kubectl apply -f ./templates/network-policy/00-default.yaml
        networkpolicy.networking.k8s.io/default-deny-ingress created

- 3.5 Проверяем доступность пода `hello-node` из пода `multitool`:

        kubectl -n multitool exec multitool-55974d5464-ttw7t -- curl -m1 10.233.90.45:8080
        % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                        Dload  Upload   Total   Spent    Left  Speed        
        0     0    0     0    0     0      0      0 --:--:--  0:00:01 --:--:--     0       
        curl: (28) Connection timed out after 1000 milliseconds
        command terminated with exit code 28

##### Дефолтная политика работает, доступа к подам в `namespace app` нет, в том числе и к `hello-node`

4. Создание политики входящего трафика для `namespace app` из `namespace multitool`:

Манифест политки следующий:

    kind: NetworkPolicy
    apiVersion: networking.k8s.io/v1
    metadata:
    name: allow-to-app-hello-node
    namespace: app
    spec:
    podSelector:
        matchLabels:
        app: hello-node
    policyTypes:
    - Ingress     
    ingress:
    - from:
        - podSelector:
            matchLabels:
            app: multitool
        namespaceSelector:
            matchLabels:
            kubernetes.io/metadata.name: multitool
        ports:
        - protocol: TCP
        port: 8080

**Примечание:**

`label` для `namespaceSelector` можно либо задать при создании namespace, либо посмотреть с помощью команды: 

    kubectl -n app describe networkpolicies allow-to-app-hello-node

    Name:         allow-to-app-hello-node
    Namespace:    app
    Created on:   2022-02-01 18:19:25 +0300 MSK
    Labels:       <none>
    Annotations:  <none>
    Spec:
    PodSelector:     app=hello-node
    Allowing ingress traffic:
        To Port: 8080/TCP
        From:
        NamespaceSelector: kubernetes.io/metadata.name=multitool
        PodSelector: app=multitool
    Not affecting egress traffic
    Policy Types: Ingress

5. Проверка доступности пода `hello-node` в `namespace app` из пода `multitool` в `namespace multitool`:

        kubectl -n multitool exec multitool-55974d5464-ttw7t -- curl 10.233.90.45:8080

        % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                        Dload  Upload   Total   Spent    Left  Speed
        100   295    0   295    0     0   287k      0 --:--:-- --:--:-- --:--:--  288k
        CLIENT VALUES:
        client_address=10.233.90.46
        command=GET
        real path=/
        query=nil
        request_version=1.1
        request_uri=http://10.233.90.45:8080/

        SERVER VALUES:
        server_version=nginx: 1.10.0 - lua: 10001

        HEADERS RECEIVED:
        accept=*/*
        host=10.233.90.45:8080
        user-agent=curl/7.79.1
        BODY:
        -no body in request

**Доступ есть!**

Проверим ping:

    kubectl -n multitool exec multitool-55974d5464-ttw7t -- ping 10.233.90.45
    PING 10.233.90.45 (10.233.90.45) 56(84) bytes of data.
    ^C

**Доступа нет, соответственно, наша политика работает.**
___
## Задание 2: изучить, что запущено по умолчанию

2.1 Результат команды `calicoctl get node`:

    root@cp1:/home/yc-user# calicoctl get node
    NAME    
    cp1
    node1

2.2 Результат команды `calicoctl get ipPool`:

    root@cp1:/home/yc-user# calicoctl get ipPool
    NAME           CIDR             SELECTOR   
    default-pool   10.233.64.0/18   all()

2.3  Результат команды `calicoctl get profile`:

    root@cp1:/home/yc-user# calicoctl get profile
    NAME
    projectcalico-default-allow
    kns.advanced-policy-demo
    kns.app
    kns.default
    kns.kube-node-lease
    kns.kube-public
    kns.kube-system
    kns.multitool
    ksa.advanced-policy-demo.default
    ksa.app.default
    ksa.default.default
    ksa.kube-node-lease.default
    ksa.kube-public.default
    ksa.kube-system.attachdetach-controller
    ksa.kube-system.bootstrap-signer
    ksa.kube-system.calico-kube-controllers
    ksa.kube-system.calico-node
    ksa.kube-system.certificate-controller
    ksa.kube-system.clusterrole-aggregation-controller
    ksa.kube-system.coredns
    ksa.kube-system.cronjob-controller
    ksa.kube-system.daemon-set-controller
    ksa.kube-system.default
    ksa.kube-system.deployment-controller
    ksa.kube-system.disruption-controller
    ksa.kube-system.dns-autoscaler
    ksa.kube-system.endpoint-controller
    ksa.kube-system.endpointslice-controller
    ksa.kube-system.endpointslicemirroring-controller
    ksa.kube-system.ephemeral-volume-controller
    ksa.kube-system.expand-controller
    ksa.kube-system.generic-garbage-collector
    ksa.kube-system.horizontal-pod-autoscaler
    ksa.kube-system.job-controller
    ksa.kube-system.kube-proxy
    ksa.kube-system.namespace-controller
    ksa.kube-system.node-controller
    ksa.kube-system.nodelocaldns
    ksa.kube-system.persistent-volume-binder
    ksa.kube-system.pod-garbage-collector
    ksa.kube-system.pv-protection-controller
    ksa.kube-system.pvc-protection-controller
    ksa.kube-system.replicaset-controller
    ksa.kube-system.replication-controller
    ksa.kube-system.resourcequota-controller
    ksa.kube-system.root-ca-cert-publisher
    ksa.kube-system.service-account-controller
    ksa.kube-system.service-controller
    ksa.kube-system.statefulset-controller
    ksa.kube-system.token-cleaner
    ksa.kube-system.ttl-after-finished-controller
    ksa.kube-system.ttl-controller
    ksa.multitool.default