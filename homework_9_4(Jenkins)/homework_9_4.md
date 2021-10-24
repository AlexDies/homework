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
                if (secret_check){
                    sh 'ansible-playbook site.yml -i inventory/prod.yml'
                }
                else{
                    echo 'need more action'
                }
                
            }
        }


1. 

2. Внести необходимые изменения, чтобы Pipeline запускал `ansible-playbook` без флагов `--check --diff`, если не установлен параметр при запуске джобы (prod_run = True), по умолчанию параметр имеет значение False и запускает прогон с флагами `--check --diff`.
3. Проверить работоспособность, исправить ошибки, исправленный Pipeline вложить в репозиторий в файл `ScriptedJenkinsfile`. Цель: получить собранный стек ELK в Ya.Cloud.
4.  Отправить ссылку на репозиторий в ответе.