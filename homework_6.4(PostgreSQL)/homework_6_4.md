## Домашнее задание к занятию "6.4. PostgreSQL"
___
**Задача 1**

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

Подключитесь к БД PostgreSQL используя `psql`.

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

Найдите и приведите управляющие команды для:

- вывода списка БД
- подключения к БД
- вывода списка таблиц
- вывода описания содержимого таблиц
- выхода из psql

___
**Выполнение ДЗ:**

**Поднятие postgresql используя докер:**

    version: '3.1'
    
    volumes:
         dbdata13:
         backup:
    
    services:
          pg_db:
            image: postgres:13
            restart: always
            environment:
              - POSTGRES_PASSWORD=test
              - POSTGRES_USER=test
            volumes:
              - dbdata13:/var/lib/postgresql/data
              - backup:/backup
            ports:
              - ${POSTGRES_PORT:-5432}:5432

**Описание команды для psql:**

- вывода списка БД
  
         \l список баз данных

- подключения к БД
  
        \c подключиться к  базе данных 

- вывода списка таблиц
  
         \dt список таблиц

- вывода описания содержимого таблиц
  
        \d NAME описывает таблицу

- выхода из psql

         \q выйти из psql

___
**Задача 2**

Используя `psql` создайте БД `test_database`.

Изучите бэкап БД.

Восстановите бэкап БД в `test_database`.

Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

Используя таблицу `pg_stats`, найдите столбец таблицы `orders` с наибольшим средним значением размера элементов в байтах.

Приведите в ответе команду, которую вы использовали для вычисления и полученный результат.
___
**Выполнение ДЗ:**

Восстановление бэкапа:

    psql -U test < /backup/test_dump.sql.1

Запуск ANALAYZE на таблицу:

    test=# analyze orders;
    ANALYZE

Вычисление столбца таблицы с наибольшим средним значением размера элементов в байтах:

    test=# select avg_width, attname FROM pg_stats WHERE tablename = 'orders' ORDER by attname DESC LIMIT 1;
    
     avg_width | attname
    -----------+---------
            16 | title
    (1 row)
___
**Задача 3**

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и поиск по ней занимает долгое время. 
Вам, как успешному выпускнику курсов DevOps в нетологии предложили провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?
___
**Выполнение ДЗ:**

Создание новой таблицы, копии orders :

    test=# create table new_orders (like orders including all);

Создание таблицы orders_1 привязанной к new_orders по критерию price >499:

      test=# create table orders_1 (like orders including all, CHECK (price > 499)) inherits ( new_orders);


      test=# \d orders_1
                                      Table "public.orders_1"
     Column |         Type          | Collation | Nullable |              Default
    --------+-----------------------+-----------+----------+------------------------------------
     id     | integer               |           | not null | nextval('orders_id_seq'::regclass)
     title  | character varying(80) |           | not null |
     price  | integer               |           |          | 0
    Indexes:
        "orders_1_pkey" PRIMARY KEY, btree (id)
    Check constraints:
        "orders_1_price_check" CHECK (price > 499)
    Inherits: new_orders
  
Создание таблицы orders_1 привязанной к new_orders по критерию price <=499:

       test=# create table orders_2 (like orders including all, CHECK (price <= 499)) inherits ( new_orders);
      
       test=# \d orders_2
                                      Table "public.orders_2"
     Column |         Type          | Collation | Nullable |              Default
    --------+-----------------------+-----------+----------+------------------------------------
     id     | integer               |           | not null | nextval('orders_id_seq'::regclass)
     title  | character varying(80) |           | not null |
     price  | integer               |           |          | 0
    Indexes:
        "orders_2_pkey" PRIMARY KEY, btree (id)
    Check constraints:
        "orders_2_price_check" CHECK (price <= 499)
    Inherits: new_orders

Создание правил для таблицы new_orders:

    test=# CREATE RULE new_orders_insert_to_2 AS ON INSERT TO new_orders WHERE (price <=499) DO INSTEAD INSERT INTO orders_2 VALUES (NEW.*);
    CREATE RULE
    test=# CREATE RULE new_orders_insert_to_1 AS ON INSERT TO new_orders WHERE (price > 499) DO INSTEAD INSERT INTO orders_1 VALUES (NEW.*);
    CREATE RULE

Копирование содержимого таблицы orders в new_orders:

    test=# INSERT INTO new_orders (id, price, title) SELECT id, price, title from orders;
    INSERT 0 0

Смотрим таблицы orders_1 и orders_2:

    test=# SELECT * FROM new_orders;
     id |        title         | price
    ----+----------------------+-------
      1 | War and peace        |   100
      3 | Adventure psql time  |   300
      4 | Server gravity falls |   300
      5 | Log gossips          |   123
      7 | Me and my bash-pet   |   499
      2 | My little database   |   500
      6 | WAL never lies       |   900
      8 | Dbiezdmin            |   501
    (8 rows)
    
    test=# SELECT * FROM orders_2;
     id |        title         | price
    ----+----------------------+-------
      1 | War and peace        |   100
      3 | Adventure psql time  |   300
      4 | Server gravity falls |   300
      5 | Log gossips          |   123
      7 | Me and my bash-pet   |   499
    (5 rows)
    
    test=# SELECT * FROM orders_1;
     id |       title        | price
    ----+--------------------+-------
      2 | My little database |   500
      6 | WAL never lies     |   900
      8 | Dbiezdmin          |   501
    (3 rows)

**Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?**

Да, можно, если бы изначально можно было бы создать наследованные таблицы по N-м ограничениям (check) и задать правила распределения данных между таблицами и партициями.

___
**P/S. 1. В сети Интернет видел разные варианты решения такой задачки, и с применением триггеров и с применением наследования (сделал выше) и с применением  декларативного секционирования.
Какой вариант наиболее предпочтительный в реальной среде?**

**2. Получается, что новая(копия order) таблица (new_order) она также существует, помимо двух наследованных order_1 и order_2 и в итоге получаем больший объём занятого место. То есть получается, мы выигрываем в скорости работы с таблицей, но проигрываем в занимаемом месте?**

**3. Дополнительно прошу проверить мой алгоритм действий выше, всё ли выполнил верно или можно было разделить таблицу из задания намного проще?**
___
**Задача 4**

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?
___
**Выполнение ДЗ:**

Создан файл бэкапа: 

    pg_dump -U test -d test > postgre13.dump

Доработка столбца title:

    Добавить UNIQUE при создании таблицы на title
    
    CREATE TABLE public.orders (
        id integer NOT NULL,
        title character varying(80) UNIQUE,
        price integer DEFAULT 0
    );
**P/S. Если что-то ещё нужно сделать, то прошу помочь, так как пока более ничего на ум не приходит по добавлению.**
___
**Доработка ДЗ 3:**

1.Создание новой таблицы с партицией по диапазону:
   
     test=# CREATE table new_orders (
          id integer NOT NULL,
          title character varying(80) NOT NULL,
          price integer DEFAULT 0
        ) partition by range ( price);
        CREATE TABLE
   
2.Создание партиции orders_1 со значением price >499:

    test=# create table orders_1 partition of new_orders for values from (500) to (2147483647);
    CREATE TABLE

3.Создание партиции orders_2 со значением price <=499:

    test=# create table orders_2 partition of new_orders for values from (0) to (500);
    CREATE TABLE

4.Проверка таблицы new_orders:

    test=# \d+ new_orders
                                      Partitioned table "public.new_orders"
     Column |         Type          | Collation | Nullable | Default | Storage  | Stats target | Description
    --------+-----------------------+-----------+----------+---------+----------+--------------+-------------
     id     | integer               |           | not null |         | plain    |              |
     title  | character varying(80) |           | not null |         | extended |              |
     price  | integer               |           |          | 0       | plain    |              |
    Partition key: RANGE (price)
    Partitions: orders_1 FOR VALUES FROM (500) TO (2147483647),
                orders_2 FOR VALUES FROM (0) TO (500)

5.Копирование информации из таблицы orders в таблицу new_orders:

    test=# INSERT into new_orders (id, price, title) select id, price, title from orders;
    INSERT 0 9
6.Проверка разделения значений по условиям:

    test=# select * FROM orders_1;
     id |       title        | price
    ----+--------------------+-------
      2 | My little database |   500
      6 | WAL never lies     |   900
      8 | Dbiezdmin          |   501
    (3 rows)

    test=# select * FROM orders_2;
     id |        title         | price
    ----+----------------------+-------
      1 | War and peace        |   100
      3 | Adventure psql time  |   300
      4 | Server gravity falls |   300
      5 | Log gossips          |   123
      7 | Me and my bash-pet   |   499
      9 | test                 |   480
    (6 rows)

    test=# select * FROM orders;
     id |        title         | price
    ----+----------------------+-------
      1 | War and peace        |   100
      2 | My little database   |   500
      3 | Adventure psql time  |   300
      4 | Server gravity falls |   300
      5 | Log gossips          |   123
      6 | WAL never lies       |   900
      7 | Me and my bash-pet   |   499
      8 | Dbiezdmin            |   501
      9 | test                 |   480
    (9 rows)

В итоге всё выполняется и работает.

**P/S. Возник вопрос при создании таблицы с партацией.** 

При полноценном копировании таблицы orders ( `CREATE table new_order (like orders including all) PARTITION BY RANGE ( price);`) или отдельном вводе primary key для столбца id (`alter table new_orders add constraint new_orders_pkey primary key (id);`) 
выдает ошибку формате:

    ERROR:  unique constraint on partitioned table must include all partitioning columns
    DETAIL:  PRIMARY KEY constraint on table "new_orders" lacks column "price" which is part of the partition key.

Получается, что при партицироовании таблицы, уникальные ключи primary_key перенести нельзя? В моем случае таблица orders (исходная) и таблица new_orders отличаются только этим ключом.
