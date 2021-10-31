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

## Подготовка к выполнению

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

Проверяем доступность по IP:8081, логин и пароль admin \ admin123. Доступ есть!

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

## Основная часть

1. 

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