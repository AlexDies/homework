# Домашнее задание к занятию "09.05 Teamcity"

## Подготовка к выполнению

1. В Ya.Cloud создайте новый инстанс (4CPU4RAM) на основе образа `jetbrains/teamcity-server`
2. Дождитесь запуска teamcity, выполните первоначальную настройку
3. Создайте ещё один инстанс(2CPU4RAM) на основе образа `jetbrains/teamcity-agent`. Пропишите к нему переменную окружения `SERVER_URL: "http://<teamcity_url>:8111"`
4. Авторизуйте агент
5. Сделайте fork [репозитория](https://github.com/aragastmatb/example-teamcity)

## Основная часть

1. Создайте новый проект в teamcity на основе fork
2. Сделайте autodetect конфигурации
3. Сохраните необходимые шаги, запустите первую сборку master'a
4. Поменяйте условия сборки: если сборка по ветке `master`, то должен происходит `mvn clean package deploy`, иначе `mvn clean test`
5. Для deploy будет необходимо загрузить [settings.xml](./teamcity/settings.xml) в набор конфигураций maven у teamcity, предварительно записав туда креды для подключения к nexus
6. В pom.xml необходимо поменять ссылки на репозиторий и nexus
7. Запустите сборку по master, убедитесь что всё прошло успешно, артефакт появился в nexus
8. Мигрируйте `build configuration` в репозиторий
9. Создайте отдельную ветку `feature/add_reply` в репозитории
10. Напишите новый метод для класса Welcomer: метод должен возвращать произвольную реплику, содержащую слово `hunter`
11. Дополните тест для нового метода на поиск слова `hunter` в новой реплике
12. Сделайте push всех изменений в новую ветку в репозиторий
13. Убедитесь что сборка самостоятельно запустилась, тесты прошли успешно
14. Внесите изменения из произвольной ветки `feature/add_reply` в `master` через `Merge`
15. Убедитесь, что нет собранного артефакта в сборке по ветке `master`
16. Настройте конфигурацию так, чтобы она собирала `.jar` в артефакты сборки
17. Проведите повторную сборку мастера, убедитесь, что сбора прошла успешно и артефакты собраны
18. Проверьте, что конфигурация в репозитории содержит все настройки конфигурации из teamcity
19. В ответ предоставьте ссылку на репозиторий

___
## Выполнение ДЗ:

### Подготовка к выполнению

0. Создаем VM под Nexus (2CPU,4RAM). Запускаем playbook:

            alexd@DESKTOP-92FN9PG:/mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/homework_9_5(TeamCity)/infrastructure$ ansible-playbook -i inventory/cicd/hosts.yml site.yml

            PLAY [Get Nexus installed] **********************************************************
            TASK [Gathering Facts] **************************************************************ok: [nexus-02]

            TASK [Create Nexus group] ***********************************************************changed: [nexus-02]

            TASK [Create Nexus user] ************************************************************changed: [nexus-02]

            TASK [Install JDK] ******************************************************************changed: [nexus-02]

            TASK [Create Nexus directories] *****************************************************changed: [nexus-02] => (item=/home/nexus/log)
            changed: [nexus-02] => (item=/home/nexus/sonatype-work/nexus3)
            changed: [nexus-02] => (item=/home/nexus/sonatype-work/nexus3/etc)
            changed: [nexus-02] => (item=/home/nexus/pkg)
            changed: [nexus-02] => (item=/home/nexus/tmp)

            TASK [Download Nexus] ***************************************************************[WARNING]: Module remote_tmp /home/nexus/.ansible/tmp did not exist and was created
            with a mode of 0700, this may cause issues when running as another user. To avoid    
            this, create the remote_tmp dir with the correct permissions manually
            changed: [nexus-02]

            TASK [Unpack Nexus] *****************************************************************changed: [nexus-02]

            TASK [Link to Nexus Directory] ******************************************************changed: [nexus-02]

            TASK [Add NEXUS_HOME for Nexus user] ************************************************changed: [nexus-02]

            TASK [Add run_as_user to Nexus.rc] **************************************************changed: [nexus-02]

            TASK [Raise nofile limit for Nexus user] ********************************************[WARNING]: The value "65536" (type int) was converted to "u'65536'" (type string).
            If this does not look like what you expect, quote the entire value to ensure it does 
            not change.
            changed: [nexus-02]

            TASK [Create Nexus service for SystemD] *********************************************changed: [nexus-02]

            TASK [Ensure Nexus service is enabled for SystemD] **********************************changed: [nexus-02]

            TASK [Create Nexus vmoptions] *******************************************************changed: [nexus-02]

            TASK [Create Nexus properties] ******************************************************changed: [nexus-02]

            TASK [Lower Nexus disk space threshold] *********************************************skipping: [nexus-02]

            TASK [Start Nexus service if enabled] ***********************************************changed: [nexus-02]

            TASK [Ensure Nexus service is restarted] ********************************************skipping: [nexus-02]

            TASK [Wait for Nexus port if started] ***********************************************ok: [nexus-02]

            PLAY RECAP **************************************************************************nexus-02                   : ok=17   changed=15   unreachable=0    failed=0    skipped=2    rescued=0    ignored=0 

Проверяем доступность по `IP:8081`, логин и пароль `admin \ admin123`. Доступ есть!

1. Создана VM (4CPU4RAM) сервера `teamcity-master` на основе образа `jetbrains/teamcity-server`
2. Запуск по адресу 178.154.206.100:8111 и дальнейшая его установка. Выбрана стандартная БД
3. Создана VM (2CPU4RAM) сервера `teamcity-agent` на основе образа ``jetbrains/teamcity-agent` с переменной:
`SERVER_URL "http://10.128.0.21:8111"`
4. В разделе `Agents` -> `Unauthorized` автроизовываем агента:

            Status
            Connected since 31 Oct 21 10:53, last communication date 31 Oct 21 10:54
            Authorized on 31 Oct 21 10:53 by admin    
            Enabled         

            Details

                Agent name: teamcity-agent
                Hostname: teamcity-agent.ru-central1.internal
                IP: 10.128.0.31
                Port: 9090
                Communication protocol: unidirectional 

            Operating system:
            Linux, version 5.4.0-81-generic
            CPU rank: 461
            Pool: Default
            Version: 99542 

5. Делаем fork репозитория `https://github.com/aragastmatb/example-teamcity`

`https://github.com/AlexDies/example-teamcity/tree/master`

___
## Основная часть

1. Создан новый проект с именем `Teamcity Netology`, выбран VCS root https://github.com/AlexDies/example-teamcity/tree/master через логин\пароль

2. После создания проекта, TC автоматически нашел конфигурацию `Maven`. Подтверждаем, появляется билд `Build Maven`.

3. Запуск сборки `master` прошел успешно, все тесты пройдены:

            [12:47:29]
            The build is removed from the queue to be prepared for the start
            [12:47:29]
            Collecting changes in 1 VCS root
            [12:47:30]
            Starting the build on the agent "teamcity-agent"
            [12:47:30]
            Updating tools for build
            [12:47:31]
            Clearing temporary directory: /opt/buildagent/temp/buildTmp
            [12:47:31]
            Publishing internal artifacts (4s)
            [12:47:31]
            Full checkout enforced. Reason: [Checkout directory is empty or doesn't exist]
            [12:47:31]
            Will perform clean checkout. Reason: Checkout directory is empty or doesn't exist
            [12:47:31]
            Checkout directory: /opt/buildagent/work/baa817be7e829315
            [12:47:31]
            Updating sources: auto checkout (on agent) (8s)
            [12:47:39]
            Step 1/1: Maven (22s)
            [12:48:02]
            Publishing internal artifacts (4s)
            [12:48:06]
            Build finished

4. Меняем условие сборки если сборка по ветке `master`, то должен происходит `mvn clean package deploy`, иначе `mvn clean test`:

4.1 В настройках `Build Maven` -> `Build Steps` -> копируем дейсивие в этот же билд.

4.2 Редактируем первый билд: 

    Step name: `Maven Test`
    Execute step -> Add condition -> Other condition:
        Parameter Name - вводи build и выбираем `teamcity.build.branch`), 
        Condition - `Does not contain`, 
        Value - `master`
    Goals: `clean test`

4.3 Редактируем второй билд:

    Step name: `Maven Deploy`
    Execute step -> Add condition -> Other condition:
        Parameter Name - вводи build и выбираем `teamcity.build.branch`), 
        Condition - `contains`, 
        Value - `master`
    Goals: `clean package deploy`

5. Проверяем файл `settings.xml` на параметры подключеняи к серверу Nexus:
    <server>
      <id>nexus</id>
      <username>admin</username>
      <password>admin123</password>
    </server>
Все параметры по умолчанию не менялись в Nexus, поэтому изменений не будет.

5.1 Добавляем файл `settings.xml` в проект. Переходим в проект `Teamcity Netology`-> `Maven Settings` -> `Upload settings file` -> Выбираем файл `settings.xml` и называем его `test`.

5.2 В `Build Configuration` изменяем настройку `Build Maven` -> `Build Step:  Maven Deploy` -> в разделе `User Setting` -> Выбираем созданный ранее сеттинг `test`. Сохраняем изменения.
 
6. В `pom.xml` меняем ссылку на локальный адрес `Nexus`: `http://10.128.0.23:8081/repository/maven-releases`

7. Запуск сборки `master`, проверка, что артефакт появляется в nexus:

        [13:23:51] The build is removed from the queue to be prepared for the start
        [13:23:51] Collecting changes in 1 VCS root
        [13:23:51] Starting the build on the agent "teamcity-agent"
        [13:23:52] Updating tools for build
        [13:23:52] Clearing temporary directory: /opt/buildagent/temp/buildTmp
        [13:23:52] Publishing internal artifacts (4s)
        [13:23:52] Using vcs information from agent file: baa817be7e829315.xml
        [13:23:52] Checkout directory: /opt/buildagent/work/baa817be7e829315
        [13:23:52] Updating sources: auto checkout (on agent)
        [13:23:53] Step 1/2: Maven Test (Maven)
        [13:23:53] [Step 1/2] Build step Maven Test (Maven) is skipped because of unfulfilled condition: "teamcity.build.branch does not contain master"
        [13:23:53] Step 2/2: Maven Deploy (Maven) (17s)
        [13:24:11] Publishing internal artifacts
        [13:24:11]Build finished

Шап 1 `Maven Test (Maven)` пропущен, так как использутся ветка `master`

В Nexus появился артефакт `plaindoll` версии `0.2.5`

8. Сохраняем конфигурации TeamCity в репозиторий:

8.1 В проекте `Teamcity Netology` -> `SSH Key` создать новый ключ и добавить `Private Key`

8.2 В настройках проекта `VCS Roots` добавляем:

            Fetch URL - git@github.com:AlexDies/example-teamcity.git 
            Uploaded Key - выбираем загруженный ранее ключ
            Username - git
Проверяем `Test connection`

8.3 В настройках проекта `Versioned Settings` -> Выбираем `Synchronization enabled` -> Выбираем созданный `VCS Root` ->` Apply`. 

Ждём сохранения конфигурации в VCS и коммит:

            Current Status:
            [16:35:07]: 	Changes from VCS are applied to project settings, last change 'TeamCity change in 'Teamcity Netology' project: Versioned settings configuration updated', revision 97b7416c5ffce05d103336f9d5b50c9eccaa93bf, time spent: 2s,104ms

9. Создаем новую ветку `feature/add_reply` от форка репозитория

10.  Добавляем новый метод для класса Welcomer: метод должен возвращать произвольную реплику, содержащую слово `hunter`:

В файле `Welcomer.java` в `main\java\plaindoll` добавляем:

        public String SaysSome() {
		    return "This is hunter";
        }

11. Добавляем новый тест для нового метода на поиск слова `hunter` в новой реплике:

В файле `WelcomerTest.java` в `test\java\plaindoll` добавляем:

        @Test
        public void welcomerSaysSome() {
            assertThat(welcomer.SaysSome(), containsString("hunter"));
        }

Пушим изменения в новую ветку

12. Сборка самостоятельно запустилась, тесты прошли успешно:

            [14:30:08] The build is removed from the queue to be prepared for the start
            [14:30:08] Collecting changes in 1 VCS root
            [14:30:09] Starting the build on the agent "teamcity-agent"
            [14:30:09] Updating tools for build
            [14:30:09] Clearing temporary directory: /opt/buildagent/temp/buildTmp
            [14:30:09] Publishing internal artifacts (4s)
            [14:30:09] Using vcs information from agent file: baa817be7e829315.xml
            [14:30:09] Checkout directory: /opt/buildagent/work/baa817be7e829315
            [14:30:09] Updating sources: auto checkout (on agent) (1s)
            [14:30:10] Step 1/2: Maven Test (Maven) (7s)
            [14:30:18] Step 2/2: Maven Deploy (Maven)
            [14:30:18] Publishing internal artifacts (1s)
            [14:30:19] Build finished

            OK 	WelcomerTest.welcomerSaysSome  (plaindoll) 	6ms 	1
            OK 	WelcomerTest.welcomerSaysFarewell  (plaindoll) 	4ms 	2
            OK 	WelcomerTest.welcomerSaysHunter  (plaindoll) 	1ms 	3
            OK 	WelcomerTest.welcomerSaysWelcome  (plaindoll) 	< 1ms 	4

13. Сделан `Merge` ветки `feature/add_reply` в `master`

14. Запускаем билд на `master` ещё раз, прроверяем, что артефактов нет:

            [15:02:38] The build is removed from the queue to be prepared for the start
            [15:02:38] Collecting changes in 1 VCS root
            [15:02:38] Starting the build on the agent "teamcity-agent"
            [15:02:43] Updating tools for build
            [15:02:43] Clearing temporary directory: /opt/buildagent/temp/buildTmp
            [15:02:43] Publishing internal artifacts (1s)
            [15:02:43] Using vcs information from agent file: baa817be7e829315.xml
            [15:02:43] Checkout directory: /opt/buildagent/work/baa817be7e829315
            [15:02:43] Updating sources: auto checkout (on agent)
            [15:02:43] Step 1/2: Maven Test (Maven)
            [15:02:43] Step 2/2: Maven Deploy (Maven) (9s)
            [15:02:53] Publishing internal artifacts (1s)
            [15:02:55] Build **finished**

            This build is in your favorites
            No user-defined artifacts in this build.
            Show hidden artifacts
            Total size: 0 B

15. Настройка конфигурации сборки так, чтобы собирался `.jar` в артефакты сборки:

В конфигурации `Build Maven` -> `General Settings` добавляем:
`Publish artifacts` - `Only if build status is successful`
`Artifact paths` - `+:target/*.jar`

16. Проводим повторную сборку мастера:

            [15:52:28] The build is removed from the queue to be prepared for the start
            [15:52:28] Collecting changes in 1 VCS root
            [15:52:28] Starting the build on the agent "teamcity-agent"
            [15:52:29] Updating tools for build
            [15:52:30] Clearing temporary directory: /opt/buildagent/temp/buildTmp
            [15:52:30] Publishing internal artifacts (4s)
            [15:52:30] Using vcs information from agent file: baa817be7e829315.xml
            [15:52:30] Checkout directory: /opt/buildagent/work/baa817be7e829315
            [15:52:30] Updating sources: auto checkout (on agent) (4s)
            [15:52:34] Step 1/2: Maven Test (Maven)
            [15:52:34] Step 2/2: Maven Deploy (Maven) (18s)
            [15:52:53] Publishing internal artifacts
            [15:52:53] Publishing artifacts (5s)
            [15:52:58] Build finished

            This build is in your favorites
            Download all (.zip)

            original-plaindoll-0.2.5.jar
            3.05 KB
            plaindoll-0.2.5.jar
            3.05 KB
            Show hidden artifacts
            Total size: 6.11 KB

Артефакты собрались успешно!

17. Проверяем конфигурацию TeamCity в репозитории: `https://github.com/AlexDies/example-teamcity`

Конфигурация обновлена и присутсвует!