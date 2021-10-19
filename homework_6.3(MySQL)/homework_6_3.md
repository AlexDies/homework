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

**Установка профиля:**

    mysql> SET profiling = 1;
    Query OK, 0 rows affected, 1 warning (0.00 sec)
    
    mysql> SHOW PROFILES;
    +----------+------------+-------------------+
    | Query_ID | Duration   | Query             |
    +----------+------------+-------------------+
    |        1 | 0.00007275 | SET profiling = 1 |
    +----------+------------+-------------------+
    1 row in set, 1 warning (0.00 sec)

**Просмотр движка таблицы:**

    mysql> SHOW TABLE STATUS \G;
    *************************** 1. row ***************************
               Name: orders
             Engine: InnoDB
            Version: 10
         Row_format: Dynamic
               Rows: 5
     Avg_row_length: 3276
        Data_length: 16384
    Max_data_length: 0
       Index_length: 0
          Data_free: 0
     Auto_increment: 6
        Create_time: 2021-07-11 13:36:40
        Update_time: 2021-07-11 13:36:40
         Check_time: NULL
          Collation: utf8mb4_0900_ai_ci
           Checksum: NULL
     Create_options:
            Comment:
    1 row in set (0.00 sec)

**Изменения движка таблицы на MyISAM:**

    mysql> ALTER TABLE orders ENGINE = MyISAM;
    Query OK, 5 rows affected (0.01 sec)
    Records: 5  Duplicates: 0  Warnings: 0


    mysql> SHOW TABLE STATUS \G;
    *************************** 1. row ***************************
               Name: orders
             Engine: MyISAM
            Version: 10
         Row_format: Dynamic
               Rows: 5
     Avg_row_length: 3276
        Data_length: 16384
    Max_data_length: 0
       Index_length: 0
          Data_free: 0
     Auto_increment: 6
        Create_time: 2021-07-11 15:40:19
        Update_time: 2021-07-11 13:36:40
         Check_time: NULL
          Collation: utf8mb4_0900_ai_ci
           Checksum: NULL
     Create_options:
            Comment:
    1 row in set (0.00 sec)

Отображение профайлера:

    mysql> SHOW PROFILES;
    +----------+------------+--------------------------------------------------+
    | Query_ID | Duration   | Query                                            |
    +----------+------------+--------------------------------------------------+
    |        7 | 0.00015525 | SHOW ENGINES                                     |
    |        8 | 0.00004175 | SHOW TABLE STATUS FROM information_schema.TABLES |
    |        9 | 0.00080800 | SHOW TABLE STATUS                                |
    |       10 | 0.00003800 | SHOW TABLE                                       |
    |       11 | 0.00064675 | SHOW TABLES                                      |
    |       12 | 0.00078575 | SHOW TABLE STATUS                                |
    |       13 | 0.00059325 | SHOW TABLE STATUS WHERE 'Engine'                 |
    |       14 | 0.00076950 | SHOW TABLE STATUS                                |
    |       15 | 0.00072975 | SHOW TABLE STATUS LIKE 'Engine'                  |
    |       16 | 0.00073875 | SHOW TABLE STATUS LIKE 'Engine'                  |
    |       17 | 0.00072375 | SHOW TABLE STATUS                                |
    |       18 | 0.00075850 | SHOW TABLE STATUS                                |
    |       19 | 0.01241000 | ALTER TABLE orders ENGINE = MyISAM               |
    |       20 | 0.00099850 | SHOW TABLE STATUS                                |
    |       21 | 0.00014675 | SELECT * FROM orders                             |
    +----------+------------+--------------------------------------------------+
**Изменения движка таблицы на InnoDB:**

    mysql> ALTER TABLE orders ENGINE = InnoDB;
    Query OK, 5 rows affected (0.02 sec)
    Records: 5  Duplicates: 0  Warnings: 0



    mysql> SHOW TABLE STATUS \G;
    *************************** 1. row ***************************
               Name: orders
             Engine: InnoDB
            Version: 10
         Row_format: Dynamic
               Rows: 5
     Avg_row_length: 3276
        Data_length: 16384
    Max_data_length: 0
       Index_length: 0
          Data_free: 0
     Auto_increment: 6
        Create_time: 2021-07-11 15:42:07
        Update_time: 2021-07-11 13:36:40
         Check_time: NULL
          Collation: utf8mb4_0900_ai_ci
           Checksum: NULL
     Create_options:
            Comment:
    1 row in set (0.00 sec)
Отображение профайлера:

    mysql> SHOW PROFILES;
    +----------+------------+------------------------------------+
    | Query_ID | Duration   | Query                              |
    +----------+------------+------------------------------------+
    |       10 | 0.00003800 | SHOW TABLE                         |
    |       11 | 0.00064675 | SHOW TABLES                        |
    |       12 | 0.00078575 | SHOW TABLE STATUS                  |
    |       13 | 0.00059325 | SHOW TABLE STATUS WHERE 'Engine'   |
    |       14 | 0.00076950 | SHOW TABLE STATUS                  |
    |       15 | 0.00072975 | SHOW TABLE STATUS LIKE 'Engine'    |
    |       16 | 0.00073875 | SHOW TABLE STATUS LIKE 'Engine'    |
    |       17 | 0.00072375 | SHOW TABLE STATUS                  |
    |       18 | 0.00075850 | SHOW TABLE STATUS                  |
    |       19 | 0.01241000 | ALTER TABLE orders ENGINE = MyISAM |
    |       20 | 0.00099850 | SHOW TABLE STATUS                  |
    |       21 | 0.00014675 | SELECT * FROM orders               |
    |       22 | 0.02536450 | ALTER TABLE orders ENGINE = InnoDB |
    |       23 | 0.00096225 | SHOW TABLE STATUS                  |
    |       24 | 0.00019550 | SELECT * FROM orders               |
    +----------+------------+------------------------------------+
    15 rows in set, 1 warning (0.00 sec)

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

**Всё что находится в файле /etc/mysql/my.conf:**

    [mysqld]
    pid-file        = /var/run/mysqld/mysqld.pid
    socket          = /var/run/mysqld/mysqld.sock
    datadir         = /var/lib/mysql
    secure-file-priv= NULL
    
    # Custom config should go here
    !includedir /etc/mysql/conf.d/

**P/S. Такое малое количество параметров обусловлено контейнером? Или по умолчанию параметров также нет и при необходимости они прописываются вручную?**

**Изменения параметров под ТЗ:**

    [mysqld]
    pid-file        = /var/run/mysqld/mysqld.pid
    socket          = /var/run/mysqld/mysqld.sock
    datadir         = /var/lib/mysql
    secure-file-priv= NULL
    
    innodb_log_buffer_size = 1M
    innodb_log_file_size = 100M
    innodb_buffer_pool_size = 700M
    innodb_file_per_table = 1
    innodb_flush_method = O_DSYNC
