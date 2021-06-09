## Домашняя работа к занятию "4.2. Использование Python для решения типовых DevOps задач"
___

 **1. Есть скрипт:**
    
        #!/usr/bin/env python3
        a = 1
        b = '2'
        c = a + b`

**Какое значение будет присвоено переменной c?**

Будет ошибка:TypeError: unsupported operand type(s) for +: 'int' and 'str'. Нельзя складывать разные типы переменных строчки и числа.

**Как получить для переменной c значение 12?**

Необходимо переменную a изменить на строковый тип str, что позволит получить результат равным 12. Например: a=str(1), или же a='1'(интерпретатор определит тип сам).

**Как получить для переменной c значение 3?**

Необходимо переменную b изменить на числовой тип int, что позволит получить результат равным 3. Например: b=int('2'), или же b=2 (интерпретатор определит тип сам).

___
**2. Мы устроились на работу в компанию, где раньше уже был DevOps Engineer. Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории, относительно локальных изменений. 
Этим скриптом недовольно начальство, потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся.
Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?**

    #!/usr/bin/env python3

    import os

    bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
    result_os = os.popen(' && '.join(bash_command)).read()
    is_change = False
    for result in result_os.split('\n'):
        if result.find('modified') != -1:
            prepare_result = result.replace('\tmodified:   ', '')
            print(prepare_result)
            break


Результат корректировки скрипта:

    #!/usr/bin/env python3
    
    import os
    
    bash_command = ["cd /home/vagrant/netology/sysadm-homeworks", "git status"]
    result_os = os.popen(' && '.join(bash_command)).read()
    is_change = False
    for result in result_os.split('\n'):
        if result.find('modified') != -1:
            prepare_result = result.replace('\tmodified:   ', '')
            print(prepare_result)
            is_change = True
        if is_change == True :
            continue

Вывод скрипта:

    vagrant@vagrant:~/netology$ ./test.py ~/netology/sysadm-homeworks/
    123
    321
    qweqweq
   
   
### Доработка домашнего задания 2:

Смутила переменная is_change = False, подумал, что данный флаг нужно использовать в скрипте)
А так действительно смысла в новом условии не было, убрал лишшнее. Результат ниже:
   
    #!/usr/bin/env python3
    
    import os
    
    bash_command = ["cd /home/vagrant/netology/sysadm-homeworks", "git status"]
    result_os = os.popen(' && '.join(bash_command)).read()
    for result in result_os.split('\n'):
        if result.find('modified') != -1:
            prepare_result = result.replace('\tmodified:   ', '')
            print(prepare_result)
          
___
**3. Доработать скрипт выше так, чтобы он мог проверять не только локальный репозиторий в текущей директории, а также умел воспринимать путь к репозиторию, который мы передаём как входной параметр. 
Мы точно знаем, что начальство коварное и будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.**

    #!/usr/bin/env python3
    
    import os
    import sys
    
    path_repo = sys.argv[1]
    bash_command = [f'cd {path_repo}', "git status"]
    result_os = os.popen(' && '.join(bash_command)).read()
    is_change = False
    for result in result_os.split('\n'):
        if result.find('modified') != -1:
            prepare_result = result.replace('\tmodified:   ', '')
            print(prepare_result)
            is_change = True
        if is_change == True :
            continue

Вывод скрипта:

    vagrant@vagrant:~/netology$ ./test.py ~/netology/testing1
    fatal: not a git repository (or any of the parent directories): .git

    vagrant@vagrant:~/netology$ ./test.py ~/netology/sysadm-homeworks/
    123
    321
    qweqweq
    
### Доработка домашнего задания 3:    

Добавил проверку на директорию через модуль os.path.exists

    #!/usr/bin/env python3

    import os
    import sys

    path_repo = sys.argv[1]
    check_dir = os.path.exists(f'{path_repo}.git')
    if check_dir != True:
        print('Данная директория не является репозиторием')
        exit()
    bash_command = [f'cd {path_repo}', "git status"]
    result_os = os.popen(' && '.join(bash_command)).read()
    for result in result_os.split('\n'):
        if result.find('modified') != -1:
            prepare_result = result.replace('\tmodified:   ', '')
            print(prepare_result)

**P/S. Подскажите, пожалуйста, а как можно было бы реализовать через try except проверку директории? Пробовал искать ошибку fatal(выводит git status), но что-то не получилось. Ранее не работал с исключениями, если есть возможность - прошу подсказать.**

Вывод скрипта:
    
    vagrant@vagrant:~/netology$ vagrant@vagrant:~/netology$ ./test.py /home/vagrant/netology/sysadm-homeworks/
    123
    321
    qweqweq
    
    vagrant@vagrant:~/netology$ ./test.py /home/vagrant/netology/testing1
    Данная директория не является репозиторием

___
**4. Наша команда разрабатывает несколько веб-сервисов, доступных по http. 
Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера, где установлен сервис. 
Проблема в том, что отдел, занимающийся нашей инфраструктурой очень часто меняет нам сервера, поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS имена. 
Это бы совсем никого не беспокоило, если бы несколько раз сервера не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. 
Мы хотим написать скрипт, который опрашивает веб-сервисы, получает их IP, выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>. 
Также, должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки. Если проверка будет провалена - оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. 
Будем считать, что наша разработка реализовала сервисы: drive.google.com, mail.google.com, google.com.**

Скрипт следующий:

    import socket
    import time
    
    ip_service = {
        "drive.google.com": '',
        'mail.google.com': '',
        'google.com': ''
        }
    while True:
        for name_service, current_ip in ip_service.items():
            check_ip = socket.gethostbyname(name_service)
            time.sleep(2)
            if check_ip != current_ip:
                ip_service[name_service] = check_ip
                print(f'[ERROR] {name_service} IP mismatch: {current_ip} New IP: {check_ip}')
            else:
                print(f'{name_service} - {current_ip}')
Вывод скрипта:

    [ERROR] drive.google.com IP mismatch:  New IP: 173.194.73.194
    [ERROR] mail.google.com IP mismatch:  New IP: 173.194.222.83
    [ERROR] google.com IP mismatch:  New IP: 64.233.162.102
    drive.google.com - 173.194.73.194
    mail.google.com - 173.194.222.83
    google.com - 64.233.162.102
    drive.google.com - 173.194.73.194
    mail.google.com - 173.194.222.83
    [ERROR] google.com IP mismatch: 64.233.162.102 New IP: 64.233.165.100
    drive.google.com - 173.194.73.194
    mail.google.com - 173.194.222.83
    google.com - 64.233.165.100
    drive.google.com - 173.194.73.194
    [ERROR] mail.google.com IP mismatch: 173.194.222.83 New IP: 64.233.165.17
    google.com - 64.233.165.100
    drive.google.com - 173.194.73.194
    mail.google.com - 64.233.165.17
    google.com - 64.233.165.100
Скрипт работает.
