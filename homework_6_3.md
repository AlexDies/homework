## Домашнее задание к занятию "6.3. MySQL"
___
**Задача 1**

Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.

Изучите бэкап БД и восстановитесь из него.

Перейдите в управляющую консоль `mysql` внутри контейнера.

Используя команду `\h` получите список управляющих команд.

Найдите команду для выдачи статуса БД и приведите в ответе из ее вывода версию сервера БД.

Подключитесь к восстановленной БД и получите список таблиц из этой БД.

Приведите в ответе количество записей с `price` > 300.

В следующих заданиях мы будем продолжать работу с данным контейнером.

___
**Выполнение ДЗ:**

Docker-compose:

        version: '3.1'
        
        services:
        
          db:
            image: mysql
            command: --default-authentication-plugin=mysql_native_password
            restart: always
            volumes:
              - dbdata_mysql1:/var/lib/mysql
              - backup1:/backup
            environment:
              MYSQL_ROOT_PASSWORD: test
            ports:
              - 3306:3306
            expose:
              - 3306
        volumes:
           dbdata_mysql1:
           backup1:

(В данном случае, расположение volumes с бд критично по отношению к env, если volumes в конфиге ниже - env не работает)

**Создаем новую БД:**

    mysql> CREATE DATABASE test_db

**Восстанавливаем бэкап:**

    mysql -p test_db < /backup/test_dump.sql

**Статус БД и вывод версии сервера:**

        mysql> \s
        --------------
        mysql  Ver 8.0.25 for Linux on x86_64 (MySQL Community Server - GPL)
        
        Connection id:          45
        Current database:
        Current user:           root@localhost
        SSL:                    Not in use
        Current pager:          stdout
        Using outfile:          ''
        Using delimiter:        ;
        Server version:         8.0.25 MySQL Community Server - GPL
        Protocol version:       10
        Connection:             Localhost via UNIX socket
        Server characterset:    utf8mb4
        Db     characterset:    utf8mb4
        Client characterset:    latin1
        Conn.  characterset:    latin1
        UNIX socket:            /var/run/mysqld/mysqld.sock
        Binary data as:         Hexadecimal
        Uptime:                 52 min 50 sec
        
        Threads: 4  Questions: 321  Slow queries: 0  Opens: 232  Flush tables: 3  Open tables: 149  Queries per second avg: 0.101

**Список таблиц:**

        mysql> SHOW TABLES;
        +-------------------+
        | Tables_in_test_db |
        +-------------------+
        | orders            |
        +-------------------+
        1 row in set (0.00 sec)

**Количество записей с price >300:**

    mysql> SELECT * FROM orders WHERE price > 300;
    +----+----------------+-------+
    | id | title          | price |
    +----+----------------+-------+
    |  2 | My little pony |   500 |
    +----+----------------+-------+
    1 row in set (0.00 sec)

___
**Задача 2**

Создайте пользователя test в БД c паролем test-pass, используя:

- плагин авторизации mysql_native_password 
- срок истечения пароля - 180 дней
- количество попыток авторизации - 3
- максимальное количество запросов в час - 100
- аттрибуты пользователя:
  - Фамилия "Pretty"
  - Имя "James"

Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.

Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и приведите в ответе к задаче.
___
**Выполнение ДЗ:**


Команда на создание пользователя:

    mysql> CREATE USER 'test'@'localhost'
        -> IDENTIFIED WITH mysql_native_password BY 'test-pass'
        -> WITH MAX_QUERIES_PER_HOUR 100
        -> PASSWORD EXPIRE INTERVAL 180 DAY
        -> FAILED_LOGIN_ATTEMPTS 3
        -> ATTRIBUTE '{"fname": "James", "lname": "Pretty"}';
    Query OK, 0 rows affected (0.01 sec)

Предоставление привелегий пользователю test на SELECT базы:

    mysql> GRANT SELECT ON *.* TO 'test'@'localhost';
    Query OK, 0 rows affected, 1 warning (0.00 sec)

Данные пользователя test:

    mysql> SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE user='test';
    +------+-----------+---------------------------------------+
    | USER | HOST      | ATTRIBUTE                             |
    +------+-----------+---------------------------------------+
    | test | localhost | {"fname": "James", "lname": "Pretty"} |
    +------+-----------+---------------------------------------+
    1 row in set (0.00 sec)

___
**Задача 3**

Установите профилирование `SET profiling = 1`. Изучите вывод профилирования команд `SHOW PROFILES;`.

Исследуйте, какой `engine `используется в таблице БД `test_db` и приведите в ответе.

Измените `engine` и приведите время выполнения и запрос на изменения из профайлера в ответе:

- на MyISAM
- на InnoDB
___
**Выполнение ДЗ:**


___
**Задача 4**

Изучите файл `my.cnf` в директории /etc/mysql.

Измените его согласно ТЗ (движок InnoDB):

- Скорость IO важнее сохранности данных
- Нужна компрессия таблиц для экономии места на диске
- Размер буффера с незакомиченными транзакциями 1 Мб
- Буффер кеширования 30% от ОЗУ
- Размер файла логов операций 100 Мб

Приведите в ответе измененный файл `my.cnf`.

___
**Выполнение ДЗ:**