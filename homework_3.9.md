## Домашняя работа к занятию "3.9. Элементы безопасности информационных систем"
---
1. __Установите Hashicorp Vault в виртуальной машине Vagrant/VirtualBox.__
2. __Запустить Vault-сервер в dev-режиме (дополнив ключ -dev упомянутым выше -dev-listen-address, если хотите увидеть UI).__

Сервер запущен и работает в dev-режиме.
     
     root@vagrant:/home/vagrant/vault# vault status
     Key             Value
     ---             -----
     Seal Type       shamir
     Initialized     true
     Sealed          false
     Total Shares    1
     Threshold       1
     Version         1.7.1
     Storage Type    inmem
     Cluster Name    vault-cluster-de7eb325
     Cluster ID      f9e61c38-ae3e-16e9-9bdf-a6910cabaafc
     HA Enabled      false

Доступ к UI присутсвует. Результат на скриншоте.

---
3. __Используя PKI Secrets Engine, создайте Root CA и Intermediate CA. Обратите внимание на дополнительные материалы по созданию CA в Vault, если с изначальной инструкцией возникнут сложности.__

Создан сертификат CA (CA_cert.crt):

    root@vagrant:/home/vagrant/vault# vault write -field=certificate pki/root/generate/internal \
     >         common_name="example.com" \
    >         ttl=87600h > CA_cert.crt
Добавлены URLs CA:

    root@vagrant:/home/vagrant/vault#  vault write pki/config/urls \
    > issuing_certificates="http://127.0.0.1/v1/pki/ca" \
    > crl_distribution_points="http://127.0.0.1/v1/pki/crl"
    Success! Data written to: pki/config/urls
Создание Intermediate CA:

    root@vagrant:/home/vagrant/vault# vault secrets enable -path=pki_int pki
    2021-05-15T09:00:33.383Z [INFO]  core: successful mount: namespace= path=pki_int/ type=pki
    Success! Enabled the pki secrets engine at: pki_int/

    root@vagrant:/home/vagrant/vault# vault secrets tune -max-lease-ttl=43800h pki_int
    2021-05-15T09:00:39.543Z [INFO]  core: mount tuning of leases successful: path=pki_int/
    Success! Tuned the secrets engine at: pki_int/

    root@vagrant:/home/vagrant/vault# vault write -format=json pki_int/intermediate/generate/internal \
    > common_name="example.com Intermediate Authority" \
    > | jq -r '.data.csr' > pki_intermediate.csr

    root@vagrant:/home/vagrant/vault#  vault write -format=json pki/root/sign-intermediate csr=@pki_intermediate.csr \
    > format=pem_bundle ttl="43800h" \
    >  | jq -r '.data.certificate' > intermediate.cert.pem

    root@vagrant:/home/vagrant/vault#  vault write pki_int/intermediate/set-signed certificate=@intermediate.cert.pem
Создание роли example-dot-com:

    root@vagrant:/home/vagrant/vault# vault write pki_int/roles/example-dot-com \
    > allowed_domains="example.com" \
    > allow_subdomains=true \
    > max_ttl="720h"
    Success! Data written to: pki_int/roles/example-dot-com
---
4. __Согласно этой же инструкции, подпишите Intermediate CA csr на сертификат для тестового домена (например, netology.example.com если действовали согласно инструкции).__

Запрос сертификата для домена netology.example.com

     root@vagrant:/home/vagrant/vault# vault write -format=json pki_int/issue/example-dot-com common_name="netology.example.com" ttl="24h" > netology.com.crt
     root@vagrant:/home/vagrant/vault# cat netology.com.crt
     {
       "request_id": "7dd45948-4fb2-c80d-c59e-c9eedaeae8a1",
       "lease_id": "",
       "lease_duration": 0,
       "renewable": false,
       "data": {
         "ca_chain": [
           "-----BEGIN CERTIFICATE-----\-----END CERTIFICATE-----"]
         "certificate": "-----BEGIN CERTIFICATE----------END CERTIFICATE----
         "expiration": 1621155897,
         "issuing_ca": "-----BEGIN CERTIFICATE----------END CERTIFICATE-----",
         "private_key": "-----BEGIN RSA PRIVATE KEY----------END RSA PRIVATE KEY-----",
         "private_key_type": "rsa",
         "serial_number": "72:d2:f8:73:44:10:f8:25:c3:40:69:56:8f:ef:ca:eb:bc:39:63:4b"
       },
       "warnings": null
     }

Создание сертификата и ключа для netology.example.com

    cat netology.com.crt | jq -r .data.certificate > netology.example.com.pem
    cat netology.com.crt | jq -r .data.issuing_ca >> netology.example.com.pem
    cat netology.com.crt | jq -r .data.private_key > netology.example.com.key
---
5. __Поднимите на localhost nginx, сконфигурируйте default vhost для использования подписанного Vault Intermediate CA сертификата и выбранного вами домена. Сертификат из Vault подложить в nginx руками.__

Добавлление в конфигурацию nginx поддержки ssl и путь к сертификатам:

    server {
            listen 80 default_server;
            listen [::]:80 default_server;
            listen 443 ssl default_server;
            listen [::]:443 ssl default_server;
            ssl_certificate /home/vagrant/vault/netology.example.com.pem;
            ssl_certificate_key /home/vagrant/vault/netology.example.com.key;
Проверяем работу nginx и перезапускаем службу:

    root@vagrant:/home/vagrant/vault# nginx -t
    nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
    nginx: configuration file /etc/nginx/nginx.conf test is successful

    root@vagrant:/home/vagrant/vault# systemctl reload nginx
    root@vagrant:/home/vagrant/vault# systemctl status nginx
    ● nginx.service - A high performance web server and a reverse proxy server
         Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
         Active: active (running) since Sat 2021-05-15 06:45:04 UTC; 2h 34min ago
           Docs: man:nginx(8)
        Process: 624 ExecStartPre=/usr/sbin/nginx -t -q -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
        Process: 629 ExecStart=/usr/sbin/nginx -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
        Process: 2105 ExecReload=/usr/sbin/nginx -g daemon on; master_process on; -s reload (code=exited, status=0/SUCCESS)
       Main PID: 630 (nginx)
          Tasks: 2 (limit: 1113)
         Memory: 13.9M
         CGroup: /system.slice/nginx.service
                 ├─ 630 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
                 └─2106 nginx: worker process
---
6. __Модифицировав /etc/hosts и системный trust-store, добейтесь безошибочной с точки зрения HTTPS работы curl на ваш тестовый домен (отдающийся с localhost). Рекомендуется добавлять в доверенные сертификаты Intermediate CA. Root CA добавить было бы правильнее, но тогда при конфигурации nginx потребуется включить в цепочку Intermediate, что выходит за рамки лекции. Так же, пожалуйста, не добавляйте в доверенные сам сертификат хоста.__

Добавление строчки 127.0.0.1 netology.example.com в /etc/hosts:

    127.0.0.1       localhost
    127.0.1.1       vagrant.vm      vagrant

    The following lines are desirable for IPv6 capable hosts
    ::1     localhost ip6-localhost ip6-loopback
    ff02::1 ip6-allnodes
    ff02::2 ip6-allrouters
    127.0.0.1 netology.example.com

Добавление в доверительные сертификат intermediate.cert.pem с разрешением .crt:

    root@vagrant:/home/vagrant/vault# cp intermediate.cert.pem /usr/local/share/ca-certificates/intermediate.cert.pem.crt

Обновление сертификатов:

    root@vagrant:/home/vagrant/vault# update-ca-certificates
    Updating certificates in /etc/ssl/certs...
    1 added, 0 removed; done.
    Running hooks in /etc/ca-certificates/update.d...
    done.

Проверка доступности nginx по HTTPS:

    root@vagrant:/home/vagrant/vault# curl -I https://netology.example.com
    HTTP/1.1 200 OK
    Server: nginx/1.18.0 (Ubuntu)
    Date: Sat, 15 May 2021 10:27:50 GMT
    Content-Type: text/html
    Content-Length: 612
    Last-Modified: Tue, 04 May 2021 17:17:21 GMT
    Connection: keep-alive
    ETag: "609181a1-264"
    Accept-Ranges: bytes
    
Доступ есть, всё работает!
