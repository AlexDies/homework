# Домашнее задание к занятию "12.1 Компоненты Kubernetes"

Вы DevOps инженер в крупной компании с большим парком сервисов. Ваша задача — разворачивать эти продукты в корпоративном кластере. 

## Задача 1: Установить Minikube

Для экспериментов и валидации ваших решений вам нужно подготовить тестовую среду для работы с Kubernetes. Оптимальное решение — развернуть на рабочей машине Minikube.

### Как поставить на AWS:
- создать EC2 виртуальную машину (Ubuntu Server 20.04 LTS (HVM), SSD Volume Type) с типом **t3.small**. Для работы потребуется настроить Security Group для доступа по ssh. Не забудьте указать keypair, он потребуется для подключения.
- подключитесь к серверу по ssh (ssh ubuntu@<ipv4_public_ip> -i <keypair>.pem)
- установите миникуб и докер следующими командами:
  - curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
  - chmod +x ./kubectl
  - sudo mv ./kubectl /usr/local/bin/kubectl
  - sudo apt-get update && sudo apt-get install docker.io conntrack -y
  - curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
- проверить версию можно командой minikube version
- переключаемся на root и запускаем миникуб: minikube start --vm-driver=none
- после запуска стоит проверить статус: minikube status
- запущенные служебные компоненты можно увидеть командой: kubectl get pods --namespace=kube-system

### Для сброса кластера стоит удалить кластер и создать заново:
- minikube delete
- minikube start --vm-driver=none

Возможно, для повторного запуска потребуется выполнить команду: sudo sysctl fs.protected_regular=0

Инструкция по установке Minikube - [ссылка](https://kubernetes.io/ru/docs/tasks/tools/install-minikube/)

**Важно**: t3.small не входит во free tier, следите за бюджетом аккаунта и удаляйте виртуалку.

## Задача 2: Запуск Hello World
После установки Minikube требуется его проверить. Для этого подойдет стандартное приложение hello world. А для доступа к нему потребуется ingress.

- развернуть через Minikube тестовое приложение по [туториалу](https://kubernetes.io/ru/docs/tutorials/hello-minikube/#%D1%81%D0%BE%D0%B7%D0%B4%D0%B0%D0%BD%D0%B8%D0%B5-%D0%BA%D0%BB%D0%B0%D1%81%D1%82%D0%B5%D1%80%D0%B0-minikube)
- установить аддоны ingress и dashboard

## Задача 3: Установить kubectl

Подготовить рабочую машину для управления корпоративным кластером. Установить клиентское приложение kubectl.
- подключиться к minikube 
- проверить работу приложения из задания 2, запустив port-forward до кластера

## Задача 4 (*): собрать через ansible (необязательное)

Профессионалы не делают одну и ту же задачу два раза. Давайте закрепим полученные навыки, автоматизировав выполнение заданий  ansible-скриптами. При выполнении задания обратите внимание на доступные модули для k8s под ansible.
 - собрать роль для установки minikube на aws сервисе (с установкой ingress)
 - собрать роль для запуска в кластере hello world
  


___
## Выполнение ДЗ:
## Задача 1: Установить Minikube

1.1 Создана ВМ в `Yandex Cloud `с параметрами CPU 2, 8 RAM с наименованием `minikube`
1.2 Удаленно подключившись по SSH, установлен первоначально `kubectl` для работы с `minikube`:

        [alexd@minikube ~]$ curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
        [alexd@minikube ~]$ chmod +x ./kubectl 
        [alexd@minikube ~]$ sudo mv ./kubectl /usr/local/bin/kubectl
1.3 Установка `Hypervisor` нам не нужен, так как мы будем использовать опцию `--vm-driver=none`, которая запускает компоненты Kubernetes на хосте, а не на виртуальной машине.

1.4 Установка `minikube`:

        [alexd@minikube ~]$ curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
        >   && chmod +x minikube
          % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                        Dload  Upload   Total   Spent    Left  Speed
        100 66.3M  100 66.3M    0     0  73.7M      0 --:--:-- --:--:-- --:--:-- 73.7M
        [alexd@minikube ~]$ sudo mv minikube /usr/local/bin/

1.5 Проверяем версию `minikube`:

        [alexd@minikube ~]$ minikube version
        minikube version: v1.24.0
        commit: 76b94fb3c4e8ac5062daf70d60cf03ddcc0a741b

1.6 Запускаем `minikub` от `root`:

        [root@minikube alexd]#minikube start --vm-driver=none
        😄  minikube v1.24.0 on Centos 7.9.2009 (amd64)
        ✨  Using the none driver based on user configuration

        🤷  Exiting due to PROVIDER_NONE_NOT_FOUND: The 'none' provider was not found: exec: "docker": executable file not found in $PATH
        💡  Suggestion: Install docker
        📘  Documentation: https://minikube.sigs.k8s.io/docs/reference/drivers/none/

Возникает ошибка, так как отсутсвует `docker` на машине. Установим его ниже.
Добавим репозиторий:

      [root@minikube alexd] yum-config-manager \
          --add-repo \
          https://download.docker.com/linux/centos/docker-ce.repo
Установим:

      [root@minikube alexd]# sudo yum install docker-ce docker-ce-cli containerd.io

Запускаем ещё раз `minikube start --vm-driver=none`:

      [root@minikube alexd]# minikube start --vm-driver=none
      😄  minikube v1.24.0 on Centos 7.9.2009 (amd64)
      ✨  Using the none driver based on existing profile
      👍  Starting control plane node minikube in cluster minikube
      🏃  Updating the running none "minikube" bare metal machine ...
      ℹ️  OS release is CentOS Linux 7 (Core)
      🐳  Preparing Kubernetes v1.22.3 on Docker 20.10.12 ...
      🤹  Configuring local host environment ...

      ❗  The 'none' driver is designed for experts who need to integrate with an existin
      g VM
      💡  Most users should use the newer 'docker' driver instead, which does not require root!
      📘  For more information, see: https://minikube.sigs.k8s.io/docs/reference/drivers/none/

      ❗  kubectl and minikube configuration will be stored in /root
      ❗  To use kubectl or minikube commands as your own user, you may need to relocate 
      them. For example, to overwrite your own settings, run:

          ▪ sudo mv /root/.kube /root/.minikube $HOME
          ▪ sudo chown -R $USER $HOME/.kube $HOME/.minikube

      💡  This can also be done automatically by setting the env var CHANGE_MINIKUBE_NONE_USER=true
      🔎  Verifying Kubernetes components...
          ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
      🌟  Enabled addons: default-storageclass, storage-provisioner
      🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default

Проверяем статус с `minikube status`:

      [root@minikube alexd]# minikube status
      minikube
      type: Control Plane
      host: Running
      kubelet: Running
      apiserver: Running
      kubeconfig: Configured

Проверим состояние кластера с помощью команды `kubectl cluster-info`:

      [root@minikube alexd]# kubectl cluster-info
      Kubernetes control plane is running at https://10.128.0.29:8443
      CoreDNS is running at https://10.128.0.29:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

      To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.  

Проверим запущенные служебные компоненты с помощью команды `kubectl get pods --namespace=kube-system`:

      [root@minikube alexd]# kubectl get pods --namespace=kube-system
      NAME                                                    READY   STATUS    RESTARTS        AGE
      coredns-78fcd69978-sdlvb                                1/1     Running   0               4m40s   
      etcd-minikube.ru-central1.internal                      1/1     Running   5 (8m34s ago)   4m50s   
      kube-apiserver-minikube.ru-central1.internal            1/1     Running   5 (8m29s ago)   4m50s   
      kube-controller-manager-minikube.ru-central1.internal   1/1     Running   5 (8m27s ago)   4m50s   
      kube-proxy-sjxzm                                        1/1     Running   0               4m40s   
      kube-scheduler-minikube.ru-central1.internal            1/1     Running   2 (5m6s ago)    4m47s   
      storage-provisioner                                     1/1     Running   0               4m48s

**По итогу - всё работает! Minikube запущен.**
___
## Задача 2: Запуск Hello World

2.1 Создание Deployment приложения `hello world` испольтзуя команду `kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4`:
 
      [root@minikube alexd]# kubectl create deployment hello-node --image=k8s.gcr.io/echoserver:1.4
      deployment.apps/hello-node created

2.2 Просмотр информации о созданном Deployment `kubectl get deployments`:

      [root@minikube alexd]# kubectl get deployments
      NAME         READY   UP-TO-DATE   AVAILABLE   AGE
      hello-node   1/1     1            1           25s

2.3 Просмотр информации о поде `kubectl get pods`:

      [root@minikube alexd]# kubectl get pods
      NAME                          READY   STATUS    RESTARTS   AGE
      hello-node-7567d9fdc9-ssgm9   1/1     Running   0          3m33s

2.4 Проверим установленные аддоны с помощью команды `minikube addons list`:

      root@minikube alexd]# minikube addons list
      |-----------------------------|----------|--------------|-----------------------|
      |         ADDON NAME          | PROFILE  |    STATUS    |      MAINTAINER       |
      |-----------------------------|----------|--------------|-----------------------|
      | ambassador                  | minikube | disabled     | unknown (third-party) |
      | auto-pause                  | minikube | disabled     | google                |
      | csi-hostpath-driver         | minikube | disabled     | kubernetes            |
      | dashboard                   | minikube | enabled ✅   | kubernetes            |
      | default-storageclass        | minikube | enabled ✅   | kubernetes            |
      | efk                         | minikube | disabled     | unknown (third-party) |
      | freshpod                    | minikube | disabled     | google                |
      | gcp-auth                    | minikube | disabled     | google                |
      | gvisor                      | minikube | disabled     | google                |
      | helm-tiller                 | minikube | disabled     | unknown (third-party) |
      | ingress                     | minikube | disabled     | unknown (third-party) |
      | ingress-dns                 | minikube | disabled     | unknown (third-party) |
      | istio                       | minikube | disabled     | unknown (third-party) |
      | istio-provisioner           | minikube | disabled     | unknown (third-party) |
      | kubevirt                    | minikube | disabled     | unknown (third-party) |
      | logviewer                   | minikube | disabled     | google                |
      | metallb                     | minikube | disabled     | unknown (third-party) |
      | metrics-server              | minikube | disabled     | kubernetes            |
      | nvidia-driver-installer     | minikube | disabled     | google                |
      | nvidia-gpu-device-plugin    | minikube | disabled     | unknown (third-party) |
      | olm                         | minikube | disabled     | unknown (third-party) |
      | pod-security-policy         | minikube | disabled     | unknown (third-party) |
      | portainer                   | minikube | disabled     | portainer.io          |
      | registry                    | minikube | disabled     | google                |
      | registry-aliases            | minikube | disabled     | unknown (third-party) |
      | registry-creds              | minikube | disabled     | unknown (third-party) |
      | storage-provisioner         | minikube | enabled ✅   | kubernetes            |
      | storage-provisioner-gluster | minikube | disabled     | unknown (third-party) |
      | volumesnapshots             | minikube | disabled     | kubernetes            |
      |-----------------------------|----------|--------------|-----------------------|

2.5 Установим аддоны `ingress` и `dashboard` командой `minikube addons enable ingress` :

      [root@minikube alexd]# minikube addons enable ingress
          ▪ Using image k8s.gcr.io/ingress-nginx/controller:v1.0.4
          ▪ Using image k8s.gcr.io/ingress-nginx/kube-webhook-certgen:v1.1.1
          ▪ Using image k8s.gcr.io/ingress-nginx/kube-webhook-certgen:v1.1.1
      🔎  Verifying ingress addon...
      🌟  The 'ingress' addon is enabled
___
## Задача 3: Установить kubectl

3.1 Установим `kubectl` на рабочую машину для управление кластером `Minukube`:

      alexd@DESKTOP-92FN9PG:~$ kubectl version --client
      Client Version: version.Info{Major:"1", Minor:"23", GitVersion:"v1.23.1",     GitCommit:"86ec240af8cbd1b60bcc4c03c20da9b98005b92e", GitTreeState:"clean", BuildDate:"2021-12-16T11:41:01Z", GoVersion:"go1.17.5", Compiler:"gc", Platform:"linux/amd64"

3.2 Пересоздание кластера с ключем `--apiserver-ips`:

Останавливаем minikube в YC с помощью `minikube stop`. Удаляем текущий класте `minikube delete` , так как нам необходимо запустить кластер с ключом `--apiserver-ips=<Внешний IP-адрес YC>`.

Запускаем кластер заново, указывая ключ `--apiserver-ips` c внешним IP:
`minikube start --apiserver-ips=84.201.158.88 --vm-driver=none`

Проверяем конфигурацию кластера по пути:

      [root@minikube alexd]# cat ~/.minikube/profiles/minikube/config.json 

      "KubernetesConfig": {
                "KubernetesVersion": "v1.22.3",
                "ClusterName": "minikube",
                "Namespace": "default",
                "APIServerName": "minikubeCA",
                "APIServerNames": null,
                "APIServerIPs": [
                        "84.201.158.88"
                ],
                "DNSDomain": "cluster.local",
                "ContainerRuntime": "docker",
                "CRISocket": "",
                "NetworkPlugin": "",
                "FeatureGates": "",
                "ServiceCIDR": "10.96.0.0/12",
                "ImageRepository": "",
                "LoadBalancerStartIP": "",
                "LoadBalancerEndIP": "",
                "CustomIngressCert": "",
                "ExtraOptions": null,
                "ShouldLoadCachedImages": false,
                "EnableDefaultCNI": false,
                "CNI": "",
                "NodeIP": "",
                "NodePort": 8443,
                "NodeName": ""
        },
        "Nodes": [
                {
                        "Name": "m01",
                        "IP": "10.128.0.29",
                        "Port": 8443,
                        "KubernetesVersion": "v1.22.3",
                        "ControlPlane": true,
                        "Worker": true

**Внешний IP-адрес прописался в параметре `APIServerIPs`**

3.3 Для подключения к minikube в облаке Яндекс необходимо перенести конфигурацию с кластера на локальный ПК:

Копируем в папку `/home/alexd/certkube` на YC конфигурацию находяющуюся по пути` ~/.kube/config`, а также сертификат из `/root/.minikube/profiles/minikube/client.crt`, `/root/.minikube/profiles/minikube/client.key`, `/root/.minikube/ca.crt`

Добавляем разрешения к файлам на чтение `chmod +r certkube/client.key certkube/config`

Переносим файл конфигурации и ключи на локальную машину с помощью `spc`:

      alexd@DESKTOP-92FN9PG:~$ scp -r alexd@84.201.158.88:/home/alexd/certkube .

Переносим сертификаты в отдельную папку по пути `~/.kube/minikubecrt/`, а файл конфигурации по пути `~/.kube/`:

      alexd@DESKTOP-92FN9PG:~$ cp certkube/client.crt ~/.kube/minikubecrt/
      alexd@DESKTOP-92FN9PG:~$ cp certkube/client.key ~/.kube/minikubecrt/
      alexd@DESKTOP-92FN9PG:~$ cp certkube/ca.crt ~/.kube/minikubecrt/
      alexd@DESKTOP-92FN9PG:~$ cp certkube/config ~/.kube/

3.4 Редактируем файл конфигурации `config` по пути `~/.kube/` для `kubctl` на локальной машине:

Редактирум параметры 

      server: https://84.201.158.88:8443
      certificate-authority: /home/alexd/.kube/minikubecrt/ca.crt
      client-certificate: /home/alexd/.kube/minikubecrt/client.crt
      client-key: /home/alexd/.kube/minikubecrt/client.key

3.5 Запускаем `kubctl cluster-info`:

      alexd@DESKTOP-92FN9PG:~$ kubectl cluster-info
      Kubernetes control plane is running at https://84.201.158.88:8443
      CoreDNS is running at https://84.201.158.88:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

      To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

      alexd@DESKTOP-92FN9PG:~$ kubectl get node
      NAME                            STATUS   ROLES                  AGE   VERSION
      minikube.ru-central1.internal   Ready    control-plane,master   21m   v1.22.3
      alexd@DESKTOP-92FN9PG:~$ kubectl get ns
      NAME              STATUS   AGE
      default           Active   21m
      kube-node-lease   Active   21m
      kube-public       Active   21m
      kube-system       Active   21m

**Доступ с локальной машины есть!**
___
3.6 Повторим установку аддонов и приложения из `п.2` выше, так как мы переустанавливали кластер. 

3.7 Создание сервиса для доступа `hello-node` извне с помощью `kubectl expose`:

      [root@minikube alexd]# kubectl expose deployment hello-node --type=NodePort --port=8080    
      service/hello-node exposed

Используем флаг `--type=NodePort` т.к. `Minikube` не поддерживает сервис `LoadBalancer`.

(Служба `NodePort` — это самый простой способ направить внешний трафик непосредственно в вашу службу. NodePort, как следует из названия, открывает определенный порт, и любой трафик, отправляемый на этот порт, перенаправляется в службу.)

Проверяем запущенный сервис с помощью команды `kubectl get services`:

      [root@minikube alexd]# kubectl get services
      NAME         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
      hello-node   NodePort    10.101.220.108   <none>        8080:32085/TCP   28s
      kubernetes   ClusterIP   10.96.0.1        <none>        443/TCP          124m

Проверяем сервис `hello-node` с помощью команды `minikube service hello-node`:

      [root@minikube alexd]# minikube service hello-node
      |-----------|------------|-------------|--------------------------|
      | NAMESPACE |    NAME    | TARGET PORT |           URL            |
      |-----------|------------|-------------|--------------------------|
      | default   | hello-node |        8080 | http://10.128.0.29:32085 |
      |-----------|------------|-------------|--------------------------|
      🎉  Opening service default/hello-node in default browser...
      👉  http://10.128.0.29:32085

Устанавливаем `socat`

Делаем `port-forwarding` до сервиса `hello-node` с помощью команды `kubectl port-forward --address 0.0.0.0 service/hello-node 8081:8080`:

      [root@minikube alexd]# kubectl port-forward --address 0.0.0.0 service/hello-node 8081:8080
      Forwarding from 0.0.0.0:8081 -> 8080

Проверям доступность приложения `hello-node` извне используя статический IP с локального ПК через `curl http://84.201.158.88:8081`:

      alexd@DESKTOP-92FN9PG:~$ curl http://84.201.158.88:8081
      CLIENT VALUES:
      client_address=127.0.0.1
      command=GET
      real path=/
      query=nil
      request_version=1.1
      request_uri=http://84.201.158.88:8080/

      SERVER VALUES:
      server_version=nginx: 1.10.0 - lua: 10001

      HEADERS RECEIVED:
      accept=*/*
      host=84.201.158.88:8081
      user-agent=curl/7.68.0
      BODY:
      -no body in request-alexd@DESKTOP-92FN9PG:~$

**Всё работает, доступ есть!**
