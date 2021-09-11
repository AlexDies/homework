## Домашнее задание к занятию "08.02 Работа с Playbook"
___
**Подготовка к выполнению**

1. Создайте свой собственный (или используйте старый) публичный репозиторий на github с произвольным именем.
2. Скачайте playbook из репозитория с домашним заданием и перенесите его в свой репозиторий.
3. Подготовьте хосты в соотвтествии с группами из предподготовленного playbook.
4. Скачайте дистрибутив java и положите его в директорию `playbook/files/`
___
**Основная часть**

1. Приготовьте свой собственный inventory файл `prod.yml`.
2. Допишите playbook: нужно сделать ещё один `play`, который устанавливает и настраивает `kibana`.
3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.
4. Tasks должны: скачать нужной версии дистрибутив, выполнить распаковку в выбранную директорию, сгенерировать конфигурацию с параметрами.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.
6. Попробуйте запустить playbook на этом окружении с флагом `--check`.
7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.
8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.
9. Подготовьте `README.md` файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.
10. Готовый playbook выложите в свой репозиторий, в ответ предоставьте ссылку на него.
___
**Выполнение ДЗ:**

**1. Подготовка файла `prod.yml` в inventory для kibana:**

**Добавлен раздел с хостом kibana:** 

        ---
        elasticsearch:
          hosts:
            localhost:
              ansible_connection: ssh
              ansible_user: root
        kibana:
          hosts:
            localhost:
              ansible_connection: ssh
              ansible_user: root

**2,3,4. Дополнить плейбук ещё одним 'play' который устанавливает `kibana`:**

**В `site.yml` добавлен следующий `play`:**

            - name: Install Kibana
              hosts: kibana
              tasks:
                - name: Upload tar.gz Kibana from remote URL
                  get_url:
                    url: "https://artifacts.elastic.co/downloads/kibana/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
                    dest: "/tmp/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
                    mode: 0755
                    timeout: 60
                    force: true
                    validate_certs: false
                  register: get_kibana
                  until: get_kibana is succeeded
                  tags: kibana
                - name: Create directrory for Kibana
                  file:
                    state: directory
                    path: "{{ kibana_home }}"
                  tags: kibana
                - name: Extract Kibana in the installation directory
                  become: true
                  unarchive:
                    copy: false
                    src: "/tmp/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
                    dest: "{{ kibana_home }}"
                    extra_opts: [--strip-components=1]
                    creates: "{{ kibana_home }}/bin/kibana"
                  tags:
                    - kibana
                - name: Set environment Kibana
                  become: true
                  template:
                    src: templates/kibana.sh.j2
                    dest: /etc/profile.d/kibana.sh
                  tags: kibana

**В `group_vars` добавлена папка `kibana` и файл `vars.yml`:**

            ---
            kibana_version: "7.14.1"
            kibana_home: "/opt/kibana/{{ kibana_version }}"
**В `templates` добавлен шаблон `kibana.sh.j2` для kibana:**

            #!/usr/bin/env bash
            
            export KIB_HOME={{ kibana_home }}
            export PATH=$PATH:$KIB_HOME/bin

**5. Запуск `ansible-lint site.yml` :**

**Первоначальный вывод ошибок:**

            alexd@DESKTOP-92FN9PG:/mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/playbook$ ansible-lint site.yml 
            WARNING  Overriding detected file kind 'yaml' with 'playbook' for given positional argument: site.yml
            WARNING  Listing 7 violation(s) that are fatal
            risky-file-permissions: File permissions unset or incorrect
            site.yml:9 Task/Handler: Upload .tar.gz file containing binaries from local storage
            
            risky-file-permissions: File permissions unset or incorrect
            site.yml:16 Task/Handler: Ensure installation dir exists
            
            risky-file-permissions: File permissions unset or incorrect
            site.yml:32 Task/Handler: Export environment variables
            
            risky-file-permissions: File permissions unset or incorrect
            site.yml:52 Task/Handler: Create directrory for Elasticsearch
            
            risky-file-permissions: File permissions unset or incorrect
            site.yml:67 Task/Handler: Set environment Elastic
            
            risky-file-permissions: File permissions unset or incorrect
            site.yml:87 Task/Handler: Create directrory for Kibana
            
            risky-file-permissions: File permissions unset or incorrect
            site.yml:102 Task/Handler: Set environment Kibana
            
            You can skip specific rules or tags by adding them to your configuration file:
            # .ansible-lint
            warn_list:  # or 'skip_list' to silence them completely
              - experimental  # all rules tagged as experimental
            
            Finished with 0 failure(s), 7 warning(s) on 1 files.

**Внесены исправления:**

            ---
            - name: Install Java
              hosts: all
              tasks:
                - name: Set facts for Java 11 vars
                  set_fact:
                    java_home: "/opt/jdk/{{ java_jdk_version }}"
                  tags: java
                - name: Upload .tar.gz file containing binaries from local storage
                  copy:
                    src: "{{ java_oracle_jdk_package }}"
                    dest: "/tmp/jdk-{{ java_jdk_version }}.tar.gz"
                    mode: 0644
                  register: download_java_binaries
                  until: download_java_binaries is succeeded
                  tags: java
                - name: Ensure installation dir exists
                  become: true
                  file:
                    state: directory
                    mode: 0644
                    path: "{{ java_home }}"
                  tags: java
                - name: Extract java in the installation directory
                  become: true
                  unarchive:
                    copy: false
                    src: "/tmp/jdk-{{ java_jdk_version }}.tar.gz"
                    dest: "{{ java_home }}"
                    extra_opts: [--strip-components=1]
                    creates: "{{ java_home }}/bin/java"
                  tags:
                    - java
                - name: Export environment variables
                  become: true
                  template:
                    src: jdk.sh.j2
                    dest: /etc/profile.d/jdk.sh
                    mode: 0644
                  tags: java
            - name: Install Elasticsearch
              hosts: elasticsearch
              tasks:
                - name: Upload tar.gz Elasticsearch from remote URL
                  get_url:
                    url: "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-{{ elastic_version }}-linux-x86_64.tar.gz"
                    dest: "/tmp/elasticsearch-{{ elastic_version }}-linux-x86_64.tar.gz"
                    mode: 0755
                    timeout: 60
                    force: true
                    validate_certs: false
                  register: get_elastic
                  until: get_elastic is succeeded
                  tags: elastic
                - name: Create directrory for Elasticsearch
                  file:
                    state: directory
                    mode: 0644
                    path: "{{ elastic_home }}"
                  tags: elastic
                - name: Extract Elasticsearch in the installation directory
                  become: true
                  unarchive:
                    copy: false
                    src: "/tmp/elasticsearch-{{ elastic_version }}-linux-x86_64.tar.gz"
                    dest: "{{ elastic_home }}"
                    extra_opts: [--strip-components=1]
                    creates: "{{ elastic_home }}/bin/elasticsearch"
                  tags:
                    - elastic
                - name: Set environment Elastic
                  become: true
                  template:
                    src: templates/elk.sh.j2
                    mode: 0644
                    dest: /etc/profile.d/elk.sh
                  tags: elastic
            - name: Install Kibana
              hosts: kibana
              tasks:
                - name: Upload tar.gz Kibana from remote URL
                  get_url:
                    url: "https://artifacts.elastic.co/downloads/kibana/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
                    dest: "/tmp/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
                    mode: 0755
                    timeout: 60
                    force: true
                    validate_certs: false
                  register: get_kibana
                  until: get_kibana is succeeded
                  tags: kibana
                - name: Create directrory for Kibana
                  file:
                    state: directory
                    mode: 0644
                    path: "{{ kibana_home }}"
                  tags: kibana
                - name: Extract Kibana in the installation directory
                  become: true
                  unarchive:
                    copy: false
                    src: "/tmp/kibana-{{ kibana_version }}-linux-x86_64.tar.gz"
                    dest: "{{ kibana_home }}"
                    extra_opts: [--strip-components=1]
                    creates: "{{ kibana_home }}/bin/kibana"
                  tags:
                    - kibana
                - name: Set environment Kibana
                  become: true
                  template:
                    src: templates/kibana.sh.j2
                    mode: 0644
                    dest: /etc/profile.d/kibana.sh
                  tags: kibana

**Вывод результата:** 

            alexd@DESKTOP-92FN9PG:/mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/playbook$ ansible-lint site.yml 
            WARNING  Overriding detected file kind 'yaml' with 'playbook' for given positional argument: site.yml

**6. Запуск playbook с флагом `--check`**:

             alexd@DESKTOP-92FN9PG:/mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/playbook$ ansible-playbook -i inventory/prod.yml site.yml --check
            
            PLAY [Install Java] *********************************************************************************
            TASK [Gathering Facts] ******************************************************************************ok: [localhost]
            
            TASK [Set facts for Java 11 vars] *******************************************************************ok: [localhost]
            
            TASK [Upload .tar.gz file containing binaries from local storage] ***********************************ok: [localhost]
            
            TASK [Ensure installation dir exists] ***************************************************************ok: [localhost]
            
            TASK [Extract java in the installation directory] ***************************************************skipping: [localhost]
            
            TASK [Export environment variables] *****************************************************************ok: [localhost]
            
            PLAY [Install Elasticsearch] ************************************************************************
            TASK [Gathering Facts] ******************************************************************************ok: [localhost]
            
            TASK [Upload tar.gz Elasticsearch from remote URL] **************************************************changed: [localhost]
            
            TASK [Create directrory for Elasticsearch] **********************************************************ok: [localhost]
            
            TASK [Extract Elasticsearch in the installation directory] ******************************************skipping: [localhost]
            
            TASK [Set environment Elastic] **********************************************************************ok: [localhost]
            
            PLAY [Install Kibana] *******************************************************************************
            TASK [Gathering Facts] ******************************************************************************ok: [localhost]
            
            TASK [Upload tar.gz Kibana from remote URL] *********************************************************changed: [localhost]
            
            TASK [Create directrory for Kibana] *****************************************************************changed: [localhost]
            
            TASK [Extract Kibana in the installation directory] *************************************************An exception occurred during task execution. To see the full traceback, use -vvv. The error was: NoneType: None
            fatal: [localhost]: FAILED! => {"changed": false, "msg": "dest '/opt/kibana/7.14.1' must be an existing dir"}
            
            PLAY RECAP ******************************************************************************************localhost                  : ok=12   changed=3    unreachable=0    failed=1    skipped=2    rescued=0    ignored=0

Возникает ошибка, так как дериктории для kibana ещё не существует.

**7. Запуск playbook на `prod.yml` окружении с флагом `--diff`:**

            alexd@DESKTOP-92FN9PG:/mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/playbook$ ansible-playbook -i inventory/prod.yml site.yml --diff
            
            PLAY [Install Java] ****************************************************************************************************************************
            TASK [Gathering Facts] *************************************************************************************************************************ok: [localhost]
            
            TASK [Set facts for Java 11 vars] **************************************************************************************************************ok: [localhost]
            
            TASK [Upload .tar.gz file containing binaries from local storage] ******************************************************************************ok: [localhost]
            
            TASK [Ensure installation dir exists] **********************************************************************************************************--- before
            +++ after
            @@ -1,4 +1,4 @@
             {
            -    "mode": "0755",
            +    "mode": "0644",
                 "path": "/opt/jdk/11.0.12"
             }
            
            changed: [localhost]
            
            TASK [Extract java in the installation directory] **********************************************************************************************skipping: [localhost]
            
            TASK [Export environment variables] ************************************************************************************************************ok: [localhost]
            
            PLAY [Install Elasticsearch] *******************************************************************************************************************
            TASK [Gathering Facts] *************************************************************************************************************************ok: [localhost]
            
            TASK [Upload tar.gz Elasticsearch from remote URL] *********************************************************************************************ok: [localhost]
            
            TASK [Create directrory for Elasticsearch] *****************************************************************************************************--- before
            +++ after
            @@ -1,4 +1,4 @@
             {
            -    "mode": "0755",
            +    "mode": "0644",
                 "path": "/opt/elastic/7.10.1"
             }
            
            changed: [localhost]
            
            TASK [Extract Elasticsearch in the installation directory] *************************************************************************************skipping: [localhost]
            
            TASK [Set environment Elastic] *****************************************************************************************************************ok: [localhost]
            
            PLAY [Install Kibana] **************************************************************************************************************************
            TASK [Gathering Facts] *************************************************************************************************************************ok: [localhost]
            
            TASK [Upload tar.gz Kibana from remote URL] ****************************************************************************************************changed: [localhost]
            
            TASK [Create directrory for Kibana] ************************************************************************************************************--- before
            +++ after
            @@ -1,5 +1,5 @@
             {
            -    "mode": "0755",
            +    "mode": "0644",
                 "path": "/opt/kibana/7.14.1",
            -    "state": "absent"
            +    "state": "directory"
             }
            
            changed: [localhost]
            
            TASK [Extract Kibana in the installation directory] ********************************************************************************************changed: [localhost]
            
            TASK [Set environment Kibana] ******************************************************************************************************************--- before
            +++ after: /home/alexd/.ansible/tmp/ansible-local-31232ckx7m11i/tmpk61vosrm/kibana.sh.j2
            @@ -0,0 +1,5 @@
            +# Warning: This file is Ansible Managed, manual changes will be overwritten on next playbook run.
            +#!/usr/bin/env bash
            +
            +export KIB_HOME=/opt/kibana/7.14.1
            +export PATH=$PATH:$KIB_HOME/bin
            \ No newline at end of file
            
            changed: [localhost]
            
            PLAY RECAP *************************************************************************************************************************************localhost                  : ok=14   changed=6    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0   

**Проверка на изменения:**
            
            [root@1410c5af69a3 /]# ls -l /opt/kibana/
            total 4
            drw-r--r-- 10 root root 4096 Sep 11 17:08 7.14.1
**Вывод env:**

            ES_HOME=/opt/elastic/7.10.1
            PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/elastic/7.10.1/bin:/opt/jdk/11.0.12/bin:/opt/kibana/7.14.1/bin
            KIB_HOME=/opt/kibana/7.14.1
            PWD=/
            JAVA_HOME=/opt/jdk/11.0.12


**8. Повторный запуск playbook с флагом `--diff`:**

            alexd@DESKTOP-92FN9PG:/mnt/c/Users/AlexD/Documents/VSCodeProject/AnsiblePlaybook/AnsiblePlaybook/playbook$ ansible-playbook -i inventory/prod.yml site.yml --diff
            
            PLAY [Install Java] ****************************************************************************************************************************
            TASK [Gathering Facts] *************************************************************************************************************************ok: [localhost]
            
            TASK [Set facts for Java 11 vars] **************************************************************************************************************ok: [localhost]
            
            TASK [Upload .tar.gz file containing binaries from local storage] ******************************************************************************ok: [localhost]
            
            TASK [Ensure installation dir exists] **********************************************************************************************************ok: [localhost]
            
            TASK [Extract java in the installation directory] **********************************************************************************************skipping: [localhost]
            
            TASK [Export environment variables] ************************************************************************************************************ok: [localhost]
            
            PLAY [Install Elasticsearch] *******************************************************************************************************************
            TASK [Gathering Facts] *************************************************************************************************************************ok: [localhost]
            
            TASK [Upload tar.gz Elasticsearch from remote URL] *********************************************************************************************ok: [localhost]
            
            TASK [Create directrory for Elasticsearch] *****************************************************************************************************ok: [localhost]
            
            TASK [Extract Elasticsearch in the installation directory] *************************************************************************************skipping: [localhost]
            
            TASK [Set environment Elastic] *****************************************************************************************************************ok: [localhost]
            
            PLAY [Install Kibana] **************************************************************************************************************************
            TASK [Gathering Facts] *************************************************************************************************************************ok: [localhost]
            
            TASK [Upload tar.gz Kibana from remote URL] ****************************************************************************************************ok: [localhost]
            
            TASK [Create directrory for Kibana] ************************************************************************************************************ok: [localhost]
            
            TASK [Extract Kibana in the installation directory] ********************************************************************************************skipping: [localhost]
            
            TASK [Set environment Kibana] ******************************************************************************************************************ok: [localhost]
            
            PLAY RECAP *************************************************************************************************************************************localhost                  : ok=13   changed=0    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0   

**Вывод: playbook идемпотентен**