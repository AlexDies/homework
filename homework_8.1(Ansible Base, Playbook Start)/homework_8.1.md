## Домашнее задание к занятию "08.01 Введение в Ansible"
___
**Подготовка к выполнению**
1. Установите ansible версии 2.10 или выше.
2. Создайте свой собственный публичный репозиторий на github с произвольным именем.
3. Скачайте `playbook` из репозитория с домашним заданием и перенесите его в свой репозиторий.
___
**Основная часть**
1. Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте какое значение имеет факт `some_fact` для указанного хоста при выполнении playbook'a.
2. Найдите файл с переменными (group_vars) в котором задаётся найденное в первом пункте значение и поменяйте его на 'all default fact'.
3. Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.
4. Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.
5. Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились следующие значения: для `deb` - 'deb default fact', для `el` - 'el default fact'.
6.  Повторите запуск playbook на окружении `prod.yml`. Убедитесь, что выдаются корректные значения для всех хостов.
7. При помощи `ansible-vault` зашифруйте факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.
8. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь в работоспособности.
9. Посмотрите при помощи `ansible-doc` список плагинов для подключения. Выберите подходящий для работы на `control node`.
10. В `prod.yml` добавьте новую группу хостов с именем  `local`, в ней разместите localhost с необходимым типом подключения.
11. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь что факты `some_fact` для каждого из хостов определены из верных `group_vars`.
12. Заполните `README.md` ответами на вопросы. Сделайте `git push` в ветку `master`. В ответе отправьте ссылку на ваш открытый репозиторий с изменённым `playbook` и заполненным `README.md`.
___
**Выполнение ДЗ Основная часть:**

1. Запуск playbook на окружении `test.yml`:

            vagrant@vagrant:~/GITHUB/AnsiblePlaybook$ ansible-playbook site.yml -i inventory/test.yml
            
            PLAY [Print os facts] ***************************************************************************
            
            TASK [Gathering Facts] **************************************************************************
            ok: [localhost]
            
            TASK [Print OS] *********************************************************************************
            ok: [localhost] => {
                "msg": "Ubuntu"
            }
            
            TASK [Print fact] *******************************************************************************
            ok: [localhost] => {
                "msg": 12
            }
            
            PLAY RECAP **************************************************************************************
            localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

Факт `some_fact` имеет значение `12`

2. В файле `group_vars/all/examp.yml` задается значение `12 `, изменим его на `'all default fact'`:

            ---
              some_fact: 12

Вывод плейбука после изменения:

            vagrant@vagrant:~/GITHUB/AnsiblePlaybook$ ansible-playbook -i inventory/test.yml site.yml
            
            PLAY [Print os facts] ***************************************************************************
            
            TASK [Gathering Facts] **************************************************************************
            ok: [localhost]
            
            TASK [Print OS] *********************************************************************************
            ok: [localhost] => {
                "msg": "Ubuntu"
            }
            
            TASK [Print fact] *******************************************************************************
            ok: [localhost] => {
                "msg": "all default fact"
            }
            
            PLAY RECAP **************************************************************************************
            localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

3. Запустим два контейнера `ubuntu` и` centos7` с установленными зависимостями python (pycontribs):

            docker run -d --name ubuntu pycontribs/ubuntu:latest sleep 600000000
            docker run -d --name centos7 pycontribs/centos:7 sleep 600000000


Проверили запущенные контейнеры: 

            vagrant@vagrant:~/GITHUB/AnsiblePlaybook$ docker ps -a
            CONTAINER ID   IMAGE                      COMMAND                  CREATED         STATUS                      PORTS                               NAMES
            b1c1e907a29c   pycontribs/ubuntu:latest   "sleep 600000000"        2 seconds ago   Up 2 seconds                                                    ubuntu
            7914d294bffe   pycontribs/centos:7        "sleep 600000000"        2 minutes ago   Up 2 minutes                                                    centos7

4. Запуск playbook на окружении `prod.yml`. Зафиксировать полученные значения `some_fact` для каждого из `managed host`

            root@vagrant:/home/vagrant/GITHUB/AnsiblePlaybook# ansible-playbook -i inventory/prod.yml site.yml
            
            PLAY [Print os facts] *************************************************************************************************************************************
            
            TASK [Gathering Facts] ************************************************************************************************************************************
            [DEPRECATION WARNING]: Distribution Ubuntu 18.04 on host ubuntu should use /usr/bin/python3, but is using /usr/bin/python for backward compatibility with
            prior Ansible releases. A future Ansible release will default to using the discovered platform python for this host. See
            https://docs.ansible.com/ansible/2.10/reference_appendices/interpreter_discovery.html for more information. This feature will be removed in version 2.12.
            Deprecation warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.
            ok: [ubuntu]
            ok: [centos7]
            
            TASK [Print OS] *******************************************************************************************************************************************
            ok: [centos7] => {
                "msg": "CentOS"
            }
            ok: [ubuntu] => {
                "msg": "Ubuntu"
            }
            
            TASK [Print fact] *****************************************************************************************************************************************
            ok: [centos7] => {
                "msg": "el"
            }
            ok: [ubuntu] => {
                "msg": "deb"
            }
            
            PLAY RECAP ************************************************************************************************************************************************
            centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
            ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

5. Изменение фактов в `group_vars/deb/examp.yml` и `group_vars/el/examp.yml`:

            ---
              some_fact: "el default fact"
            
            
            ---
              some_fact: "deb default fact"
   
6. Проверить playbook на `prod.yml`:

            root@vagrant:/home/vagrant/GITHUB/AnsiblePlaybook# ansible-playbook -i inventory/prod.yml site.yml
            
            PLAY [Print os facts] *************************************************************************************************************************************
            
            TASK [Gathering Facts] ************************************************************************************************************************************
            [DEPRECATION WARNING]: Distribution Ubuntu 18.04 on host ubuntu should use /usr/bin/python3, but is using /usr/bin/python for backward compatibility with
            prior Ansible releases. A future Ansible release will default to using the discovered platform python for this host. See
            https://docs.ansible.com/ansible/2.10/reference_appendices/interpreter_discovery.html for more information. This feature will be removed in version 2.12.
            Deprecation warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.
            ok: [ubuntu]
            ok: [centos7]
            
            TASK [Print OS] *******************************************************************************************************************************************
            ok: [centos7] => {
                "msg": "CentOS"
            }
            ok: [ubuntu] => {
                "msg": "Ubuntu"
            }
            
            TASK [Print fact] *****************************************************************************************************************************************
            ok: [centos7] => {
                "msg": "el default fact"
            }
            ok: [ubuntu] => {
                "msg": "deb default fact"
            }
            
            PLAY RECAP ************************************************************************************************************************************************
            centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
            ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

7. Осуществление шифрования с помощью `ansible-vault` фактов в `group_vars/deb` и `group_vars/el` с паролем `netology`

            root@vagrant:/home/vagrant/GITHUB/AnsiblePlaybook# ansible-vault encrypt group_vars/deb/examp.yml
            New Vault password:
            Confirm New Vault password:
            Encryption successful
            
            root@vagrant:/home/vagrant/GITHUB/AnsiblePlaybook# ansible-vault encrypt group_vars/el/examp.yml
            New Vault password:
            Confirm New Vault password:
            Encryption successful

8. Запуск playbook с окружением `prod.yml` и ключом `--ask-vault-pass` для запроса пароля:

            root@vagrant:/home/vagrant/GITHUB/AnsiblePlaybook# ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass
            Vault password:
            
            PLAY [Print os facts] *************************************************************************************************************************************
            
            TASK [Gathering Facts] ************************************************************************************************************************************
            [DEPRECATION WARNING]: Distribution Ubuntu 18.04 on host ubuntu should use /usr/bin/python3, but is using /usr/bin/python for backward compatibility with
            prior Ansible releases. A future Ansible release will default to using the discovered platform python for this host. See
            https://docs.ansible.com/ansible/2.10/reference_appendices/interpreter_discovery.html for more information. This feature will be removed in version 2.12.
            Deprecation warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.
            ok: [ubuntu]
            ok: [centos7]
            
            TASK [Print OS] *******************************************************************************************************************************************
            ok: [centos7] => {
                "msg": "CentOS"
            }
            ok: [ubuntu] => {
                "msg": "Ubuntu"
            }
            
            TASK [Print fact] *****************************************************************************************************************************************
            ok: [centos7] => {
                "msg": "el default fact"
            }
            ok: [ubuntu] => {
                "msg": "deb default fact"
            }
            
            PLAY RECAP ************************************************************************************************************************************************
            centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
            ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

9. Просмотр документации списка плагинов для подключения с помощью `ansible-doc`. Выбор подходящей для` control node`:

Выведем список всех connection добавив ключ `-t connection --list`:

            root@vagrant:/home/vagrant/GITHUB/AnsiblePlaybook# ansible-doc -t connection --list
            ansible.netcommon.httpapi      Use httpapi to run command on network appliances
            ansible.netcommon.libssh       (Tech preview) Run tasks using libssh for ssh connection
            ansible.netcommon.napalm       Provides persistent connection using NAPALM
            ansible.netcommon.netconf      Provides a persistent connection using the netconf protocol
            ansible.netcommon.network_cli  Use network_cli to run command on network appliances
            ansible.netcommon.persistent   Use a persistent unix socket for connection
            community.aws.aws_ssm          execute via AWS Systems Manager
            community.general.chroot       Interact with local chroot
            community.general.docker       Run tasks in docker containers
            community.general.funcd        Use funcd to connect to target
            community.general.iocage       Run tasks in iocage jails
            community.general.jail         Run tasks in jails
            community.general.lxc          Run tasks in lxc containers via lxc python library
            community.general.lxd          Run tasks in lxc containers via lxc CLI
            community.general.oc           Execute tasks in pods running on OpenShift
            community.general.qubes        Interact with an existing QubesOS AppVM
            community.general.saltstack    Allow ansible to piggyback on salt minions
            community.general.zone         Run tasks in a zone instance
            community.kubernetes.kubectl   Execute tasks in pods running on Kubernetes
            community.libvirt.libvirt_lxc  Run tasks in lxc containers via libvirt
            community.libvirt.libvirt_qemu Run tasks on libvirt/qemu virtual machines
            community.vmware.vmware_tools  Execute tasks inside a VM via VMware Tools
            containers.podman.buildah      Interact with an existing buildah container
            containers.podman.podman       Interact with an existing podman container
            local                          execute on controller
            paramiko_ssh                   Run tasks via python ssh (paramiko)
            psrp                           Run tasks over Microsoft PowerShell Remoting Protocol
            ssh                            connect via ssh client binary
            winrm                          Run tasks over Microsoft's WinRM

Выбрать для `control node` какого-то одного конкретного типа трудно, так как мне кажется, всё зависит от задачи.
Я выделю такие типы как: ssh, docker, kubernetes.kubectl, aws.aws_ssm.

**P/S. Правильны ли эти варианты? Или есть какой-то универсальный вариант? Или ещё какие-то?**


10. Добавление новой группы хостов с именем `local` в `prod.yml`. Размещение `localhost` с локальным подключением `local`:

            ---
              el:
                hosts:
                  centos7:
                    ansible_connection: docker
              deb:
                hosts:
                  ubuntu:
                    ansible_connection: docker
              local:
                hosts:
                  localhost:
                    ansible_connection: local

11. Запуск playbook на окружении `prod.yml`:

            root@vagrant:/home/vagrant/GITHUB/AnsiblePlaybook# ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass
            Vault password:
            
            PLAY [Print os facts] *************************************************************************************************************************************
            
            TASK [Gathering Facts] ************************************************************************************************************************************
            ok: [localhost]
            [DEPRECATION WARNING]: Distribution Ubuntu 18.04 on host ubuntu should use /usr/bin/python3, but is using /usr/bin/python for backward compatibility with
            prior Ansible releases. A future Ansible release will default to using the discovered platform python for this host. See
            https://docs.ansible.com/ansible/2.10/reference_appendices/interpreter_discovery.html for more information. This feature will be removed in version 2.12.
            Deprecation warnings can be disabled by setting deprecation_warnings=False in ansible.cfg.
            ok: [ubuntu]
            ok: [centos7]
            
            TASK [Print OS] *******************************************************************************************************************************************
            ok: [localhost] => {
                "msg": "Ubuntu"
            }
            ok: [centos7] => {
                "msg": "CentOS"
            }
            ok: [ubuntu] => {
                "msg": "Ubuntu"
            }
            
            TASK [Print fact] *****************************************************************************************************************************************
            ok: [localhost] => {
                "msg": "all default fact"
            }
            ok: [centos7] => {
                "msg": "el default fact"
            }
            ok: [ubuntu] => {
                "msg": "deb default fact"
            }
            
            PLAY RECAP ************************************************************************************************************************************************
            centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
            localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
            ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

Определил для каждой группы хостов свои факты

12. Ответы на вопросы в README.md в репозитории: https://github.com/AlexDies/AnsiblePlaybook

___
**Необязательная часть**

1. При помощи `ansible-vault` расшифруйте все зашифрованные файлы с переменными.
2. Зашифруйте отдельное значение `PaSSw0rd` для переменной `some_fact` паролем `netology`. Добавьте полученное значение в `group_vars/all/exmp.yml`.
3. Запустите `playbook`, убедитесь, что для нужных хостов применился новый `fact`.
4. Добавьте новую группу хостов `fedora`, самостоятельно придумайте для неё переменную. В качестве образа можно использовать [этот](https://hub.docker.com/r/pycontribs/fedora).
5. Напишите скрипт на bash: автоматизируйте поднятие необходимых контейнеров, запуск ansible-playbook и остановку контейнеров.
6. Все изменения должны быть зафиксированы и отправлены в вашей личный репозиторий.
___
**Выполнение ДЗ Необязательная часть:**

1. Расшифровка при помощи `ansible-vault` файлов в каталоге `group_vars`:

            root@vagrant:/home/vagrant/GITHUB/AnsiblePlaybook# ansible-vault decrypt group_vars/deb/examp.yml
            Vault password:
            Decryption successful
            
            
            root@vagrant:/home/vagrant/GITHUB/AnsiblePlaybook# ansible-vault decrypt group_vars/el/examp.yml
            Vault password:
            Decryption successful

2. Шифрование переменной `some_fact` значением `PaSSw0rd` и паролем `netology`. Добавление полученного шифрованного значения в `group_vars/all/exmp.yml`:

Зашифровали текст `PaSSw0rd`:

            root@vagrant:/home/vagrant/GITHUB/AnsiblePlaybook# ansible-vault encrypt_string "PaSSw0rd" --ask-vault-pass
            New Vault password:
            Confirm New Vault password:
            !vault |
                      $ANSIBLE_VAULT;1.1;AES256
                      38393664623863323234356234353131313633376231313435383262613363343666626537336130
                      6437353930353034346134353163366130353265646465630a333666376437623939303764363864
                      32626630643439653166333435633730363965313639646336383665636634393562323634393165
                      3932613136353165350a656636633733303834643263393533313464383966636639386266313933
                      3264
            Encryption successful

Подставили в переменную `some_fact` в `group_vars/all/exmp.yml`:

            ---
              some_fact: !vault |
                      $ANSIBLE_VAULT;1.1;AES256
                      38393664623863323234356234353131313633376231313435383262613363343666626537336130
                      6437353930353034346134353163366130353265646465630a333666376437623939303764363864
                      32626630643439653166333435633730363965313639646336383665636634393562323634393165
                      3932613136353165350a656636633733303834643263393533313464383966636639386266313933
                      3264

3. Запуск playbook с обновлением зашифрованного факта:

            root@vagrant:/home/vagrant/GITHUB/AnsiblePlaybook# ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass
            Vault password:
            
            PLAY [Print os facts] ***********************************************************************************
            
            TASK [Gathering Facts] **********************************************************************************
            ok: [localhost]
            [DEPRECATION WARNING]: Distribution Ubuntu 18.04 on host ubuntu should use /usr/bin/python3, but is
            using /usr/bin/python for backward compatibility with prior Ansible releases. A future Ansible release
            will default to using the discovered platform python for this host. See
            https://docs.ansible.com/ansible/2.10/reference_appendices/interpreter_discovery.html for more
            information. This feature will be removed in version 2.12. Deprecation warnings can be disabled by
            setting deprecation_warnings=False in ansible.cfg.
            ok: [ubuntu]
            ok: [centos7]
            
            TASK [Print OS] *****************************************************************************************
            ok: [localhost] => {
                "msg": "Ubuntu"
            }
            ok: [centos7] => {
                "msg": "CentOS"
            }
            ok: [ubuntu] => {
                "msg": "Ubuntu"
            }
            
            TASK [Print fact] ***************************************************************************************
            ok: [localhost] => {
                "msg": "PaSSw0rd"
            }
            ok: [centos7] => {
                "msg": "el default fact"
            }
            ok: [ubuntu] => {
                "msg": "deb default fact"
            }
            
            PLAY RECAP **********************************************************************************************
            centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
            localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
            ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

Запрос пароля происходит успешно, после расшифровки виден пароль

4. Добавление новой группы хостов `fedora`:

Добавление группы `fed` c хостами` fedora`:

            ---
              el:
                hosts:
                  centos7:
                    ansible_connection: docker
              deb:
                hosts:
                  ubuntu:
                    ansible_connection: docker
              local:
                hosts:
                  localhost:
                    ansible_connection: local
              fed:
                hosts:
                  fedora:
                    ansible_connection: docker

Создание файла с переменными `group_vars/fed/examp.yml`:
            
            ---
              some_fact: !vault |
                      $ANSIBLE_VAULT;1.1;AES256
                      38393664623863323234356234353131313633376231313435383262613363343666626537336130
                      6437353930353034346134353163366130353265646465630a333666376437623939303764363864
                      32626630643439653166333435633730363965313639646336383665636634393562323634393165
                      3932613136353165350a656636633733303834643263393533313464383966636639386266313933
                      3264

Поднимаем docker-образ с fedora:

            docker run -d --name fedora pycontribs/fedora sleep 600000000

Результат вывода команды ansible-playbook:

            root@vagrant:/home/vagrant/GITHUB/AnsiblePlaybook# ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass
            Vault password:
            
            PLAY [Print os facts] ***********************************************************************************
            
            TASK [Gathering Facts] **********************************************************************************
            ok: [localhost]
            ok: [fedora]
            [DEPRECATION WARNING]: Distribution Ubuntu 18.04 on host ubuntu should use /usr/bin/python3, but is
            using /usr/bin/python for backward compatibility with prior Ansible releases. A future Ansible release
            will default to using the discovered platform python for this host. See
            https://docs.ansible.com/ansible/2.10/reference_appendices/interpreter_discovery.html for more
            information. This feature will be removed in version 2.12. Deprecation warnings can be disabled by
            setting deprecation_warnings=False in ansible.cfg.
            ok: [ubuntu]
            ok: [centos7]
            
            TASK [Print OS] *****************************************************************************************
            ok: [localhost] => {
                "msg": "Ubuntu"
            }
            ok: [fedora] => {
                "msg": "Fedora"
            }
            ok: [centos7] => {
                "msg": "CentOS"
            }
            ok: [ubuntu] => {
                "msg": "Ubuntu"
            }
            
            TASK [Print fact] ***************************************************************************************
            ok: [localhost] => {
                "msg": "PaSSw0rd"
            }
            ok: [centos7] => {
                "msg": "el default fact"
            }
            ok: [ubuntu] => {
                "msg": "deb default fact"
            }
            ok: [fedora] => {
                "msg": "PaSSw0rd"
            }
            
            PLAY RECAP **********************************************************************************************
            centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
            fedora                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
            localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
            ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

**В итоге - всё работает.**

5. Bash-скрипт:

        #!/bin/bash
        docker run -d --name ubuntu pycontribs/ubuntu:latest sleep 600000000
        docker run -d --name centos7 pycontribs/centos:7 sleep 600000000
        docker run -d --name fedora pycontribs/fedora sleep 600000000
        echo 'docker run'
        ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass
        
        docker stop ubuntu
        docker rm ubuntu
        echo 'rm ubuntu'
        docker stop fedora
        docker rm fedora
        echo 'rm fedora'
        docker stop centos7
        docker rm centos7
        echo 'rm centos7'
        echo 'end'
