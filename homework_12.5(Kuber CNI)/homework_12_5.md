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

1. Плагин Calico установлен по умолчанию в кластере после установке через kuberspray:

    alexd@DESKTOP-92FN9PG:/mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook$ kubectl get pods -A     
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

2. Установка приложения для проверки политики


root@cp1:/home/yc-user# cat /etc/cloud/templates/hosts.debian.tmpl 
## template:jinja
{#
This file (/etc/cloud/templates/hosts.debian.tmpl) is only utilized
if enabled in cloud-config.  Specifically, in order to enable it
you need to add the following to config:
   manage_etc_hosts: True
-#}
# Your system has configured 'manage_etc_hosts' as True.
# As a result, if you wish for changes to this file to persist
# then you will need to either
# a.) make changes to the master file in /etc/cloud/templates/hosts.debian.tmpl      
# b.) change or remove the value of 'manage_etc_hosts' in
#     /etc/cloud/cloud.cfg or cloud-config from user-data
#
{# The value '{{hostname}}' will be replaced with the local-hostname -#}
127.0.1.1 {{fqdn}} {{hostname}}
127.0.0.1 localhost localhost.localdomain

# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback localhost6 localhost6.localdomain
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

# Ansible inventory hosts BEGIN
10.128.0.16 cp1.cluster.local cp1
10.128.0.20 node1.cluster.local node1
# Ansible inventory hosts END
51.250.12.188 lb-apiserver.kubernetes.local




root@cp1:/home/yc-user# cat /etc/hosts
# Your system has configured 'manage_etc_hosts' as True.
# As a result, if you wish for changes to this file to persist
# then you will need to either
# a.) make changes to the master file in /etc/cloud/templates/hosts.debian.tmpl      
# b.) change or remove the value of 'manage_etc_hosts' in
#     /etc/cloud/cloud.cfg or cloud-config from user-data
#
127.0.1.1 fhmdt3ip81auq46h720q.auto.internal fhmdt3ip81auq46h720q
127.0.0.1 localhost localhost.localdomain

# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback localhost6 localhost6.localdomain
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

# Ansible inventory hosts BEGIN
10.128.0.16 cp1.cluster.local cp1
10.128.0.20 node1.cluster.local node1
# Ansible inventory hosts END
51.250.12.188 lb-apiserver.kubernetes.local



root@node1:/home/yc-user# cat /etc/hostname 
node1
root@node1:/home/yc-user# cat /etc/hosts
# Your system has configured 'manage_etc_hosts' as True.
# As a result, if you wish for changes to this file to persist
# then you will need to either
# a.) make changes to the master file in /etc/cloud/templates/hosts.debian.tmpl      
# b.) change or remove the value of 'manage_etc_hosts' in
#     /etc/cloud/cloud.cfg or cloud-config from user-data
#
127.0.1.1 fhm22ho1nvnqisr2dfco.auto.internal fhm22ho1nvnqisr2dfco
127.0.0.1 localhost localhost.localdomain

# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback localhost6 localhost6.localdomain
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

# Ansible inventory hosts BEGIN
10.128.0.16 cp1.cluster.local cp1
10.128.0.20 node1.cluster.local node1
# Ansible inventory hosts END
51.250.12.188 lb-apiserver.kubernetes.local





3. Настройка политики



4. Проверка доступа к приложению извне:

___
## Задание 2: изучить, что запущено по умолчанию