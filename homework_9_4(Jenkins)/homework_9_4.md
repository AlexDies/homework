# Домашнее задание к занятию "09.04 Jenkins"

## Подготовка к выполнению

1. Создать 2 VM: для jenkins-master и jenkins-agent.
2. Установить jenkins при помощи playbook'a.
3. Запустить и проверить работоспособность.
4. Сделать первоначальную настройку.
___
## Основная часть

1. Сделать Freestyle Job, который будет запускать `molecule test` из любого вашего репозитория с ролью.
2. Сделать Declarative Pipeline Job, который будет запускать `molecule test` из любого вашего репозитория с ролью.
3. Перенести Declarative Pipeline в репозиторий в файл `Jenkinsfile`.
4. Создать Multibranch Pipeline на запуск `Jenkinsfile` из репозитория.
5. Создать Scripted Pipeline, наполнить его скриптом из [pipeline](./pipeline).
6. Внести необходимые изменения, чтобы Pipeline запускал `ansible-playbook` без флагов `--check --diff`, если не установлен параметр при запуске джобы (prod_run = True), по умолчанию параметр имеет значение False и запускает прогон с флагами `--check --diff`.
7. Проверить работоспособность, исправить ошибки, исправленный Pipeline вложить в репозиторий в файл `ScriptedJenkinsfile`. Цель: получить собранный стек ELK в Ya.Cloud.
8. Отправить ссылку на репозиторий в ответе.
___
## Необязательная часть

1. Создать скрипт на groovy, который будет собирать все Job, которые завершились хотя бы раз неуспешно. Добавить скрипт в репозиторий с решеним с названием `AllJobFailure.groovy`.
2. Дополнить Scripted Pipeline таким образом, чтобы он мог сначала запустить через Ya.Cloud CLI необходимое количество инстансов, прописать их в инвентори плейбука и после этого запускать плейбук. Тем самым, мы должны по нажатию кнопки получить готовую к использованию систему.

___
## Выполнение ДЗ:

## Подготовка:
1. Создал 2 VM на ya.cloud - 2ГБ и 2 ядра.
2. Скачал и запустил playbook. На этапе загрузки Ansible на хост-agent возникла следующая ошибка:

            Traceback (most recent call last):
            (КУЧА ЛОГА)
            File "/usr/local/lib/python3.6/site-packages/pip/_internal/utils/unpacking.py", line 226, in untar_file
                with open(path, "wb") as destfp:
            UnicodeEncodeError: 'ascii' codec can't encode character '\xe9' in position 117: ordinal not in range(128)

Проблема заключается в кодировке, которая используется - вместо `ASCII` необходимо использовать `en_US.UTF-8`.

Доработан `playbook`:
- Добавлена таска

      - name: Export environment variables
            become_user: root
            template:
              src: test.sh.j2
              dest: /etc/profile.d/test.sh
              mode: 0755
- Добавлен шаблон `test.sh.j2`:
            #!/usr/bin/env bash

        export LC_CTYPE=en_US.UTF-8
        export LC_ALL=en_US.UTF-8

После этого, `playbook` пройден успешно!

3. Запуск `jenkins` успешен.
4.1 В  настройках необходимо перейти в `master` и в поле `Настроить` - убрать `Nubmer of executors` на `0` (весто 2 по умолчанию), так как у нас на мастере не нужны сборщики, а только на агенте.

4.2 Добавляем нового агента:
- Имя `Linux-agent-01`
- Количество сборщиков - `2`
- Корень удаленной ФС: `/opt/jenkins_agent/`
- Метка - `Linux`
- Тип подключения: `Launch agent via execution of command on the controller`
  Команда для запуска: `ssh 178.154.200.100 java -jar /opt/jenkins_agent/agent.jar`

Агент готов к работе и 2 сборщика активны!
___
## Основная часть

1. Создан `Item` - `задача со свободной конфигурацией` - `Freestyle Job`
1.1 Выбран Label - `linux`
1.2 `Управление исходным кодом` -> `GIT` -> Репозиторий `git@github.com:AlexDies/kibana-role.git` -> добавлен приватный ключ в Credentials
1.3 Выбрана ветка `*/kibana_role(molecule)`
1.4 Добавил саб-директорию по названию роли молекулы, так как мы находится сейчас в директории `Freestyle Job`: 
`Additional Behaviours` -> `Check out to a sub-directory` -> `kibana-role `
1.5 Добавление пункта `Сборка` ->` Выполнить команду shell`:

            cd kibana-role (переход в саб-папку)
            mkdir molecule/default/files  (так как в роли нет папки files)
            pip3 install molecule-docker (так как в requirements к роли отсутсвует docker)
            pip3 install -r test-requirements.txt
            molecule test

1.5 Запуск джоба нажатием `Собрать сейчас` прошел успешно:

        INFO     Pruning extra files from scenario ephemeral directory

        Finished: SUCCESS


2.1 Создан `Declarative Pipeline Job`:  `Item` - `Pipeline` - `kibana-role`
2.2 В `Pipeline` выбран - `Pipeline script`. Задан следующий скрипт:

            pipeline {
                agent {
                    label 'linux'
                }
                stages {
                    stage('Git Check') {
                        steps{
                            git branch: 'kibana_role(molecule)', credentialsId: '555e5b54-c114-4c38-92a4-07a3f0bc647c', url: 'git@github.com:AlexDies/kibana-role.git'
                        }
                    }
                    stage('Install molecule') {
                        steps{
                            sh 'mkdir molecule/default/files'
                            sh 'pip3 install molecule-docker'
                            sh 'pip3 install -r test-requirements.txt' 
                        }
                    }
                    stage('Run Molecule') {
                        steps{
                            sh 'molecule test'
                        }
                    }    
                    
                }
            }

2.2 Запуск `Declarative Pipeline` прошел успешно:

            [Pipeline] }
            [Pipeline] // stage
            [Pipeline] }
            [Pipeline] // node
            [Pipeline] End of Pipeline
            Finished: SUCCESS

3. Перенос `Declarative Pipeline` в репозиторий в файл `Jenkinsfile`:
   
4.Создание `Multibranch Pipeline` на запуск `Jenkinsfile` из репозитория в отдельной папке.
4.1 Проверка запуска:

        Checking branches...
        Checking branch kibana_role(molecule)
            ‘Jenkinsfile’ found
            Met criteria
        Scheduled build for branch: kibana_role(molecule)
        Checking branch main
            ‘Jenkinsfile’ found
            Met criteria
        Scheduled build for branch: main
        Processed 2 branches
        [Sun Oct 24 18:35:14 UTC 2021] Finished branch indexing. Indexing took 7.2 sec
        Finished: SUCCESS

        INFO     Pruning extra files from scenario ephemeral directory
        [Pipeline] }
        [Pipeline] // stage
        [Pipeline] }
        [Pipeline] // withEnv
        [Pipeline] }
        [Pipeline] // node
        [Pipeline] End of Pipeline
        Finished: SUCCESS

5. Создание `Scripted Pipeline` со скриптом `pipeline` из вложения в отдельной папке
5.1 Добавление пунтка `Это - параметризованная сборка`. Добавлена `Boolean Parameter`: `secret_check`
5.2 Добавлен код:

        node("linux"){
            stage("Git checkout"){
                git credentialsId: '555e5b54-c114-4c38-92a4-07a3f0bc647c', url: 'git@github.com:aragastmatb/example-playbook.git'
            }
            stage("Sample define secret_check"){
                secret_check=true
            }
            stage("Ansible Role Download"){
                'sh ansible-galaxy install -r requirements.yml -p roles'
            }
            stage("Run playbook"){
                if (params.ecret_check){
                    sh 'ansible-playbook site.yml -i inventory/prod.yml'
                }
                else{
                    echo 'need more action'
                }
                
            }
        }

5.3 Добавлен ключ пользователя Jenkins с сервера-агента в GIT, чтобы можно было выкчивать роли.

6.1 Создан отдельный pipeline playbook со следующим содержимым:

6.2 Запуск джобы без галочки

            Started by user admin1
            [Pipeline] Start of Pipeline
            [Pipeline] node
            Running on Linux-agent-01 in /opt/jenkins_agent/workspace/ScriptTest/playbook
            [Pipeline] {
            [Pipeline] stage
            [Pipeline] { (Git checkout)
            [Pipeline] git
            The recommended git tool is: NONE
            using credential 555e5b54-c114-4c38-92a4-07a3f0bc647c
            Fetching changes from the remote Git repository
            > git rev-parse --resolve-git-dir /opt/jenkins_agent/workspace/ScriptTest/playbook/.git # timeout=10
            > git config remote.origin.url git@github.com:AlexDies/AnsiblePlaybook.git # timeout=10
            Fetching upstream changes from git@github.com:AlexDies/AnsiblePlaybook.git
            > git --version # timeout=10
            > git --version # 'git version 1.8.3.1'
            using GIT_SSH to set credentials 
            [INFO] Currently running in a labeled security context
            [INFO] Currently SELinux is 'enforcing' on the host
            > /usr/bin/chcon --type=ssh_home_t /opt/jenkins_agent/workspace/ScriptTest/playbook@tmp/jenkins-gitclient-ssh4244686603523034890.key
            > git fetch --tags --progress git@github.com:AlexDies/AnsiblePlaybook.git +refs/heads/*:refs/remotes/origin/* # timeout=10
            Checking out Revision 6dac47c969490680972c0cbc79c143aab6de3b26 (refs/remotes/origin/Ansible_8_4)
            Commit message: "add md"
            > git rev-parse refs/remotes/origin/Ansible_8_4^{commit} # timeout=10
            > git config core.sparsecheckout # timeout=10
            > git checkout -f 6dac47c969490680972c0cbc79c143aab6de3b26 # timeout=10
            > git branch -a -v --no-abbrev # timeout=10
            > git branch -D Ansible_8_4 # timeout=10
            > git checkout -b Ansible_8_4 6dac47c969490680972c0cbc79c143aab6de3b26 # timeout=10
            > git rev-list --no-walk 6dac47c969490680972c0cbc79c143aab6de3b26 # timeout=10
            [Pipeline] }
            [Pipeline] // stage
            [Pipeline] stage
            [Pipeline] { (Sample define secret_check)
            [Pipeline] }
            [Pipeline] // stage
            [Pipeline] stage
            [Pipeline] { (Ansible Role Download)
            [Pipeline] sh
            + ansible-galaxy install -r /opt/jenkins_agent/workspace/ScriptTest/playbook/playbook/requirements.yml -p /opt/jenkins_agent/workspace/ScriptTest/playbook/playbook/roles
            Starting galaxy role install process

            - extracting elastic to /opt/jenkins_agent/workspace/ScriptTest/playbook/playbook/roles/elastic
            - elastic (2.0.0) was installed successfully

            - extracting kibana to /opt/jenkins_agent/workspace/ScriptTest/playbook/playbook/roles/kibana
            - kibana (1.1.1) was installed successfully

            - extracting filebeat to /opt/jenkins_agent/workspace/ScriptTest/playbook/playbook/roles/filebeat
            - filebeat (1.0.1) was installed successfully
            [Pipeline] }
            [Pipeline] // stage
            [Pipeline] stage
            [Pipeline] { (Run playbook)
            [Pipeline] sh
            + ansible-playbook /opt/jenkins_agent/workspace/ScriptTest/playbook/playbook/site.yml -i /opt/jenkins_agent/workspace/ScriptTest/playbook/playbook/inventory/prod.yml --check --diff

            [WARNING]: Unable to parse
            /opt/jenkins_agent/workspace/ScriptTest/playbook/playbook/inventory/prod.yml as
            an inventory source
            [WARNING]: No inventory was parsed, only implicit localhost is available
            [WARNING]: provided hosts list is empty, only localhost is available. Note that
            the implicit localhost does not match 'all'
            [WARNING]: Could not match supplied host pattern, ignoring: elasticsearch

            PLAY [Install Elasticsearch] ***************************************************
            skipping: no hosts matched
            [WARNING]: Could not match supplied host pattern, ignoring: kibana

            PLAY [Install kibana] **********************************************************
            skipping: no hosts matched
            [WARNING]: Could not match supplied host pattern, ignoring: app

            PLAY [Install Filebeat] ********************************************************
            skipping: no hosts matched

            PLAY RECAP *********************************************************************

            [Pipeline] }
            [Pipeline] // stage
            [Pipeline] }
            [Pipeline] // node
            [Pipeline] End of Pipeline
            Finished: SUCCESS



7. Внести необходимые изменения, чтобы Pipeline запускал `ansible-playbook` без флагов `--check --diff`, если не установлен параметр при запуске джобы (prod_run = True), по умолчанию параметр имеет значение False и запускает прогон с флагами `--check --diff`.
8. Проверить работоспособность, исправить ошибки, исправленный Pipeline вложить в репозиторий в файл `ScriptedJenkinsfile`. Цель: получить собранный стек ELK в Ya.Cloud.
9.  Отправить ссылку на репозиторий в ответе.