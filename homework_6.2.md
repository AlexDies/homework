## Домашнее задание к занятию "6.2. SQL"
___
**Задача 1**

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.
___
**Выполнение ДЗ:**

Docker-compose манифест:

    version: '3.1'
    
    volumes:
      dbdata:
      backup:
    
    services:
      pg_db:
        image: postgres:12
        restart: always
        environment:
          - POSTGRES_PASSWORD=test
          - POSTGRES_USER=test
        volumes:
          - dbdata:/var/lib/postgresql/data
          - backup:/backup
        ports:
          - ${POSTGRES_PORT:-5432}:5432

___
**Задача 2**

В БД из задачи 1:

- создайте пользователя test-admin-user и БД test_db
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
- создайте пользователя test-simple-user
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

Таблица orders:

- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:

- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Приведите:

- итоговый список БД после выполнения пунктов выше,
- описание таблиц (describe)
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
- список пользователей с правами над таблицами test_db
___
**Выполнение ДЗ:**
**Создание test_admin_user:**

      test=# CREATE USER test_admin_user;
      CREATE ROLE

      test=# \password

      Enter new password:
      Enter it again:

      test=# \du
                                            List of roles
          Role name    |                         Attributes                         | Member of
      -----------------+------------------------------------------------------------+-----------
       test            | Superuser, Create role, Create DB, Replication, Bypass RLS | {}
       test_admin_user |                                                            | {}
**Создание БД test_db:**

    test=# CREATE DATABASE test_db;
    CREATE DATABASE
**Создание таблицы orders и clients:**

    test_db=# CREATE TABLE orders (id SERIAL NOT NULL primary key, наименование TEXT, цена INT);
    
    CREATE TABLE
    
    test_db=# CREATE TABLE clients (id SERIAL NOT NULL primary key, фамилия TEXT, страна_проживания TEXT, заказ
    test_db(# SERIAL NOT NULL REFERENCES orders (id));
    
    CREATE TABLE

Список таблиц:

      test_db=# \d clients
                                          Table "public.clients"
            Column       |  Type   | Collation | Nullable |                 Default
      -------------------+---------+-----------+----------+------------------------------------------
       id                | integer |           | not null | nextval('clients_id_seq'::regclass)
       фамилия           | text    |           |          |
       страна_проживания | text    |           |          |
       заказ             | integer |           | not null | nextval('"clients_заказ_seq"'::regclass)
      Indexes:
          "clients_pkey" PRIMARY KEY, btree (id)
      Foreign-key constraints:
          "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)
      


      test_db=# \d orders
                                     Table "public.orders"
          Column    |  Type   | Collation | Nullable |              Default
      --------------+---------+-----------+----------+------------------------------------
       id           | integer |           | not null | nextval('orders_id_seq'::regclass)
       наименование | text    |           |          |
       цена         | integer |           |          |
      Indexes:
          "orders_pkey" PRIMARY KEY, btree (id)
      Referenced by:
          TABLE "clients" CONSTRAINT "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)
**Предоставление привилегии на все операции пользователю test_admin_user на таблицы БД test_db:**

    test_db=# GRANT ALL ON orders TO test_admin_user ;
    GRANT
    test_db=# GRANT ALL ON clients TO test_admin_user ;
    GRANT
**Создание пользователя test_simple_user:**

    test_db=# CREATE USER test_simple_user WITH PASSWORD 'test';
    
    CREATE ROLE

**Предоставление пользователю test_simple_user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db:**

    test_db=# GRANT SELECT, UPDATE, INSERT, DELETE ON clients TO test_simple_user ;
    GRANT
    test_db=# GRANT SELECT, UPDATE, INSERT, DELETE ON orders TO test_simple_user ;
    GRANT

**Список пользователей с правами на таблицы:**

    test_db=# \dp
                                                  Access privileges
         Schema |       Name        |   Type   |      Access privileges       | Column privileges | Policies
        --------+-------------------+----------+------------------------------+-------------------+----------
         public | clients           | table    | test=arwdDxt/test           +|                   |
                |                   |          | test_admin_user=arwdDxt/test+|                   |
                |                   |          | test_simple_user=arwd/test   |                   |
         public | clients_id_seq    | sequence |                              |                   |
         public | clients_заказ_seq | sequence |                              |                   |
         public | orders            | table    | test=arwdDxt/test           +|                   |
                |                   |          | test_admin_user=arwdDxt/test+|                   |
                |                   |          | test_simple_user=arwd/test   |                   |
         public | orders_id_seq     | sequence |                              |                   |
        (5 rows)

**P/S. Непонятно, о каком именно SQL-запросе списка пользователей с правами на таблицы идёт речь. Если же о \dp или \dp clients , \dp orders, то результат отразил выше.
Если же речь о другом - прошу помочь, каких-то отдельных запросов найти не удалось..**
___
**Задача 3**

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица  orders

Наименование | цена
:-------- |:-----:
Шоколад | 10
Принтер | 3000
Книга| 500
Монитор | 7000
Гитара 	| 4000


Таблица clients

ФИО | Страна проживания
:-------- |:-----:
Иванов Иван Иванович |	USA
Петров Петр Петрович |	Canada
Иоганн Себастьян Бах |	Japan
Ронни Джеймс Дио |	Russia
Ritchie Blackmore |	Russia

Используя SQL синтаксис:

- вычислите количество записей для каждой таблицы
- приведите в ответе:
  - запросы
  - результаты их выполнения.
___
**Выполнение ДЗ:**

**Добавление данных в таблицы:**

Таблица orders:

    test_db=# INSERT INTO orders VALUES (1,'Шоколад',10);
    INSERT 0 1
    test_db=# INSERT INTO orders VALUES (2,'Принтер',3000);
    INSERT 0 1
    test_db=# INSERT INTO orders VALUES (3,'Книга',500);
    INSERT 0 1
    test_db=# INSERT INTO orders VALUES (4,'Монитор',7000);
    INSERT 0 1
    test_db=# INSERT INTO orders VALUES (5,'Гитара',4000);
    INSERT 0 1
Таблица clients:



___  
**Задача 4**

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

ФИО |	Заказ
:-------- |:-----:
Иванов Иван Иванович |	Книга
Петров Петр Петрович |	Монитор
Иоганн Себастьян Бах |	Гитара

Приведите SQL-запросы для выполнения данных операций.

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.

Подсказк - используйте директиву UPDATE.
___
Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 (используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.
___
**Задача 6**

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления.