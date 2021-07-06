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

    test_db=# CREATE TABLE orders (id SERIAL NOT NULL primary key, наименование VARCHAR NOT NULL, цена INTEGER NOT NULL);
    CREATE TABLE
        
      
    test_db=# CREATE TABLE clients (id SERIAL NOT NULL primary key, фамилия VARCHAR NOT NULL, страна_проживания VARCHAR NOT NULL, заказ SERIAL
     NOT NULL REFERENCES orders (id));
    CREATE TABLE
    
    test_db=# CREATE INDEX страна_проживания ON clients (страна_проживания);
    CREATE INDEX

Список таблиц:

     test_db=# \d clients
                                             Table "public.clients"
          Column       |       Type        | Collation | Nullable |                 Default
    -------------------+-------------------+-----------+----------+------------------------------------------
     id                | integer           |           | not null | nextval('clients_id_seq'::regclass)
     фамилия           | character varying |           | not null |
     страна_проживания | character varying |           | not null |
     заказ             | integer           |           | not null | nextval('"clients_заказ_seq"'::regclass)
    Indexes:
        "clients_pkey" PRIMARY KEY, btree (id)
        "страна_проживания" btree ("страна_проживания")
    Foreign-key constraints:
        "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)


    test_db=# \d orders
                                        Table "public.orders"
        Column    |       Type        | Collation | Nullable |              Default
    --------------+-------------------+-----------+----------+------------------------------------
     id           | integer           |           | not null | nextval('orders_id_seq'::regclass)
     наименование | character varying |           | not null |
     цена         | integer           |           | not null |
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

**P/S. 1. Непонятно, о каком именно SQL-запросе списка пользователей с правами на таблицы идёт речь. Если же о \dp или \dp clients , \dp orders, то результат отразил выше.
Если же речь о другом - прошу помочь, каких-то отдельных запросов найти не удалось..**

**2.Также немного непонятно, как аналогичную информацию можно посмотреть в IDE, например, в DBeaver? Только "ручками" перебирая все? Нельзя ли использоваить функционал psql по типу \dp или же есть всё же SQL-запрос?**

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

    test_db=# INSERT INTO orders (наименование,цена) VALUES ('Шоколад',10);
    INSERT 0 1
    test_db=# INSERT INTO orders (наименование,цена) VALUES ('Принтер',3000);
    INSERT 0 1
    test_db=# INSERT INTO orders (наименование,цена) VALUES ('Книга',500);
    INSERT 0 1
    test_db=# INSERT INTO orders (наименование,цена) VALUES ('Монитор',7000);
    INSERT 0 1
    test_db=# INSERT INTO orders (наименование,цена) VALUES ('Гитара',4000);
    INSERT 0 1


    test_db=# SELECT * FROM orders;
     id | наименование | цена
    ----+--------------+------
      1 | Шоколад      |   10
      2 | Принтер      | 3000
      3 | Книга        |  500
      4 | Монитор      | 7000
      5 | Гитара       | 4000
    (5 rows)

Таблица clients:

    test_db=# INSERT INTO clients (фамилия,страна_проживания) VALUES ('Иванов Иван Иванович','USA');
    INSERT 0 1
    test_db=# INSERT INTO clients (фамилия,страна_проживания) VALUES ('Петров Петр Петрович','Canada');
    INSERT 0 1
    test_db=# INSERT INTO clients (фамилия,страна_проживания) VALUES ('Иоганн Себастьян Бах','Japan');
    INSERT 0 1
    test_db=# INSERT INTO clients (фамилия,страна_проживания) VALUES ('Ронни Джеймс Дио','Russia');
    INSERT 0 1
    test_db=# INSERT INTO clients (фамилия,страна_проживания) VALUES ('Ritchie Blackmore','Russia');

    test_db=# SELECT * FROM clients;
     id |       фамилия        | страна_проживания | заказ
    ----+----------------------+-------------------+-------
      1 | Иванов Иван Иванович | USA               |     1
      2 | Петров Петр Петрович | Canada            |     2
      3 | Иоганн Себастьян Бах | Japan             |     3
      4 | Ронни Джеймс Дио     | Russia            |     4
      5 | Ritchie Blackmore    | Russia            |     5
    (5 rows)

**Количество записей в таблице:**

    test_db=# SELECT COUNT (*) FROM clients;
     count
    -------
         5
    (1 row)


    test_db=# SELECT COUNT (*) FROM orders;
     count
    -------
         5
    (1 row)
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
**Выполнение ДЗ:**

**SQL-запросы для выполнения данных операций**

    test_db=# UPDATE clients SET заказ=3 WHERE id=1;
    UPDATE 1
    
    test_db=# UPDATE clients SET заказ=4 WHERE id=2;
    UPDATE 1
    
    test_db=# UPDATE clients SET заказ=5 WHERE id=3;
    UPDATE 1
**SQL-запрос для выдачи всех пользователей, которые сделали заказ**

    test_db=# SELECT фамилия,заказ FROM clients WHERE id <> заказ;


           фамилия        | заказ
    ----------------------+-------
     Иванов Иван Иванович |     3
     Петров Петр Петрович |     4
     Иоганн Себастьян Бах |     5
    (3 rows)

**P/S. Так как мы не фиксируем дату покупки, то отсортировать за последнее время пока не придумал как, решил отсортировать по значению id не равным заказу, так как по умолчанию, таблица заполняется id=заказ(1-1,2-2 и т.д)**

**Прошу подсказать, какой вариант выборки в данном случае будет наиболее подходяий и верно ли я выбрал метод?**
___
**Задача 5**

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 (используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.
___
**Выполнение ДЗ:**

**Информация о запросе:**

    test_db=# EXPLAIN SELECT фамилия,заказ FROM clients WHERE id <> заказ;
                           QUERY PLAN
    --------------------------------------------------------
     Seq Scan on clients  (cost=0.00..1.06 rows=5 width=37)
       Filter: (id <> "заказ")
    (2 rows)

Данный результат показывает анализ информации по проведенному запросу с помощью плана выполнения

cost - приблизительное время (0.00), которое было потрачено на первое значение(первой строчки) и время затраченное на получение всех строк (1.06)

rows - ожидаемое число строк, которое должен быть выведен

width - ожидаемый средний размер строк в байтах
___
**Задача 6**

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления.
___
**Выполнение ДЗ:**



