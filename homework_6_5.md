## Домашнее задание к занятию "6.5. Elasticsearch"
___
**Задача 1**

В этом задании вы потренируетесь в:

- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ centos:7 как базовый и документацию по установке и запуску Elastcisearch:

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:

- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:

- текст Dockerfile манифеста
- ссылку на образ в репозитории dockerhub
- ответ `elasticsearch` на запрос пути` /` в json виде

Подсказки:

- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch.
___
**Выполнение ДЗ:**

Составление dockerfile:

    FROM centos:7
    
    RUN yum update -y && \
          yum install wget -y && \
          yum install perl-Digest-SHA -y && \
          yum install java-1.8.0-openjdk.x86_64 -y
    
    WORKDIR /usr/elastic/
    
    RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.13.3-linux-x86_64.tar.gz && \
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.13.3-linux-x86_64.tar.gz.sha512
    
    RUN shasum -a 512 -c elasticsearch-7.13.3-linux-x86_64.tar.gz.sha512 && \
    tar -xzf elasticsearch-7.13.3-linux-x86_64.tar.gz
    
    RUN groupadd -g 3000 elasticsearch && \
        adduser -u 3000 -g elasticsearch -s /bin/sh elasticsearch && \
        chmod 777 -R /var/lib/ && \
        chmod 777 -R /usr/elastic/elasticsearch-7.13.3/
    
    USER 3000
    EXPOSE 9200
    EXPOSE 9300
    
    WORKDIR /usr/elastic/elasticsearch-7.13.3/bin/
    
    CMD ["./elasticsearch", "-Enode.name=netology_test", "-Epath.data=/var/lib/data", "-Epath.logs=/var/lib/logs", "-Enetwork.host=0.0.0.0", "-Ediscovery.type=single-node"]

Подать команду на лимиты на хостовой машине для устранения лимита: 

    bootstrap check failure [1] of [2]: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]


        sudo sysctl -w vm.max_map_count=262144
        vm.max_map_count = 262144

Запуск docker с ограничением по памяти:

    docker run -p 9200:9200 --name elastictest --memory="1g" -d elastic

    vagrant@vagrant:~$ docker ps -a
    CONTAINER ID   IMAGE            COMMAND                  CREATED         STATUS                      PORTS                               NAMES
    2731d1bb9398   elastic          "./elasticsearch -En…"   5 minutes ago   Up 5 minutes                0.0.0.0:9200->9200/tcp, 9300/tcp    elastictest

Вывод в Json ответа на запрос "вне" докера:

    vagrant@vagrant:~$ curl -X GET "localhost:9200/?pretty"
    {
      "name" : "netology_test",
      "cluster_name" : "elasticsearch",
      "cluster_uuid" : "co7mtcP4QmqlncoB9H5k0w",
      "version" : {
        "number" : "7.13.3",
        "build_flavor" : "default",
        "build_type" : "tar",
        "build_hash" : "5d21bea28db1e89ecc1f66311ebdec9dc3aa7d64",
        "build_date" : "2021-07-02T12:06:10.804015202Z",
        "build_snapshot" : false,
        "lucene_version" : "8.8.2",
        "minimum_wire_compatibility_version" : "6.8.0",
        "minimum_index_compatibility_version" : "6.0.0-beta1"
      },
      "tagline" : "You Know, for Search"
    }

Присвоен тэг `elastic`:

    docker tag a2b5c87e2ef7 alexdies/homework:elastic

Отправлен Image в dockerhub:

    docker push alexdies/homework:elastic

Ссылка на dockerhub:

https://hub.docker.com/layers/alexdies/homework/elastic/images/sha256-fe3d44f69fb51efa6a9097fa85dd4dcd3561ea7ddd94f0d91d2db6dce7d96b67?context=repo

**P/S. 1. Изначально не хотел делать перенос файла elasticsearch.yml через COPY в dockerfile, а прописать всё в конфиге, но столкнулся с большим
количество добавления переменных окружения в CMD. Подскажите, пожалуйста, как лучше всего структурировать dockerfile? 
Через отдельный файл конфигурации или же можно и мой вариант? (если рассматриваем реальный кейс на проде).**

**2. Пробовал обновить лимиты на память, так как JVM сжирало все через переменные elastic в docker при запуске в следующем виде:**

docker run -p 9200:9200 -e "discovery.type=single-node" -e "-Xms1g -Xmx1g"  --name elastictest -d elastic

**Но результата это не дало. А также переменная discovery.type=single-node тоже не работала, пока не поместил её в dockerfile.
В чем может быть проблема?**
___
**Задача 2**

В этом задании вы научитесь:

- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с документацией и добавьте в elasticsearch 3 индекса, в соответствии со таблицей:

        Имя  Количество реплик 	Количество шард
        ind-1 	0 	            1
        ind-2 	1 	            2
        ind-3 	2 	            4

Получите список индексов и их статусов, используя API и приведите в ответе на задание.

Получите состояние кластера `elasticsearch`, используя API.

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

Удалите все индексы.

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард, иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.
___
**Выполнение ДЗ:**

Создание индекса `ind-1`:

    vagrant@vagrant:~$ curl -X PUT "localhost:9200/ind-1?pretty" -H 'Content-Type: application/json' -d'
    > {
    >  "settings":{
    >   "number_of_shards": 1,
    >   "number_of_replicas": 0
    >  }
    > }
    > '
    {
      "acknowledged" : true,
      "shards_acknowledged" : true,
      "index" : "ind-1"
    }

Создание индекса `ind-2`:

    vagrant@vagrant:~$ curl -X PUT "localhost:9200/ind-2?pretty" -H 'Content-Type: application/json' -d'
    {
     "settings":{
      "number_of_shards": 2,
      "number_of_replicas": 1
     }
    }
    '
    {
      "acknowledged" : true,
      "shards_acknowledged" : true,
      "index" : "ind-2"
    }

Создание индекса `ind-3`:

    vagrant@vagrant:~$ curl -X PUT "localhost:9200/ind-3?pretty" -H 'Content-Type: application/json' -d'
    {
     "settings":{
      "number_of_shards": 4,
      "number_of_replicas": 2
     }
    }
    '
    {
      "acknowledged" : true,
      "shards_acknowledged" : true,
      "index" : "ind-3"
    }

Состояние шард `_cat/shards` :

    vagrant@vagrant:~$ curl -X GET "localhost:9200/_cat/shards?pretty&v=true"
    index shard prirep state      docs store ip         node
    ind-1 0     p      STARTED       0  208b 172.17.0.2 netology_test
    ind-2 1     p      STARTED       0  208b 172.17.0.2 netology_test
    ind-2 1     r      UNASSIGNED
    ind-2 0     p      STARTED       0  208b 172.17.0.2 netology_test
    ind-2 0     r      UNASSIGNED
    ind-3 1     p      STARTED       0  208b 172.17.0.2 netology_test
    ind-3 1     r      UNASSIGNED
    ind-3 1     r      UNASSIGNED
    ind-3 2     p      STARTED       0  208b 172.17.0.2 netology_test
    ind-3 2     r      UNASSIGNED
    ind-3 2     r      UNASSIGNED
    ind-3 3     p      STARTED       0  208b 172.17.0.2 netology_test
    ind-3 3     r      UNASSIGNED
    ind-3 3     r      UNASSIGNED
    ind-3 0     p      STARTED       0  208b 172.17.0.2 netology_test
    ind-3 0     r      UNASSIGNED
    ind-3 0     r      UNASSIGNED

Состояние кластера `_cluster/health`:

    vagrant@vagrant:~$ curl -X GET "localhost:9200/_cluster/health?pretty"
    {
      "cluster_name" : "elasticsearch",
      "status" : "yellow",
      "timed_out" : false,
      "number_of_nodes" : 1,
      "number_of_data_nodes" : 1,
      "active_primary_shards" : 7,
      "active_shards" : 7,
      "relocating_shards" : 0,
      "initializing_shards" : 0,
      "unassigned_shards" : 10,
      "delayed_unassigned_shards" : 0,
      "number_of_pending_tasks" : 0,
      "number_of_in_flight_fetch" : 0,
      "task_max_waiting_in_queue_millis" : 0,
      "active_shards_percent_as_number" : 41.17647058823529
    }

Удаление индексов:

    vagrant@vagrant:~$ curl -X DELETE "localhost:9200/ind-1?pretty"
    {
      "acknowledged" : true
    }
    vagrant@vagrant:~$ curl -X DELETE "localhost:9200/ind-2?pretty"
    {
      "acknowledged" : true
    }
    vagrant@vagrant:~$ curl -X DELETE "localhost:9200/ind-3?pretty"
    {
      "acknowledged" : true
    }


По полученной информации видим, что кластер находится в "status" : "yellow". Это говорит о том, что все primary шарды в состоянии `assigned`, а replicas шарды в состоянии `unassigned`.

Шарды `replicas` находящиеся в состоянии `unassigned` из-за того, что они не привязаны ни к одной ноде. Так как у нас всего 1 нода в этой схеме.


**P/S. 1. Получается, что реплики всегда должны быть на разных узлах, иначе система будет считать, что они не привязаны? (`unassigned`). Т.е. реприка 1 шарда 1 должна быть на ноде с шардом 2, а реплика шарда 2 на ноде с шардом 1. Немного не до конца понятно**

**2. Получается, нет смысла делать реплики, если используется одна нода?**

**3. Количества шард при 1 ноде, получается можно делать неограниченно? Есть ли в этом смысл для повышения быстродействия?**
___
**Задача 3**

В данном задании вы научитесь:

- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API зарегистрируйте данную директорию как `snapshot repository` c именем `netology_backup`.

Приведите в ответе запрос API и результат вызова API для создания репозитория.

Создайте индекс `test` с 0 реплик и 1 шардом и приведите в ответе список индексов.

Создайте `snapshot` состояния кластера `elasticsearch`.

Приведите в ответе список файлов в директории со `snapshot`ами.

Удалите индекс `test` и создайте индекс` test-2`. Приведите в ответе список индексов.

Восстановите состояние кластера `elasticsearch` из `snapshot`, созданного ранее.

Приведите в ответе запрос к API восстановления и итоговый список индексов.

Подсказки:

- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`
___
**Выполнение ДЗ:**

Создание директории:

    mkdir /usr/elastic/elasticsearch-7.13.3/snapshots

Добавление path.repo в elasticsearch.yml:

    path.repo: /usr/elastic/elasticsearch-7.13.3/snapshots

Перезапуск elasticsearch:

    docker restart elastictest

Регистрация репозитория snapshot с именем `netology_backup`:

    vagrant@vagrant:~$ curl -X PUT "localhost:9200/_snapshot/netology_backup?pretty" -H 'Content-Type: application/json' -d'
    > {
    >   "type": "fs",
    >   "settings": {
    >      "location": "netology_backup_location"
    >   }
    > }
    > '
    {
      "acknowledged" : true
    }

Информация о репозитории `netology_backup`:

    vagrant@vagrant:~$ curl -X GET "localhost:9200/_snapshot/netology_backup?pretty"
    {
      "netology_backup" : {
        "type" : "fs",
        "settings" : {
          "location" : "netology_backup_location"
        }
      }
    }

Создание индекса `test` с репликой 0 и шардом 1:

    vagrant@vagrant:~$ curl -X PUT "localhost:9200/test?pretty" -H 'Content-Type: application/json' -d'
    > {
    > "settings":{
    >   "number_of_shards": 1,
    >   "number_of_replicas": 0
    >   }
    > }
    > '
    {
      "acknowledged" : true,
      "shards_acknowledged" : true,
      "index" : "test"
    }

Создание `snapshot` состояния кластера:

    vagrant@vagrant:~$ curl -X PUT "localhost:9200/_snapshot/netology_backup/snapshot_test?wait_for_completion=true&pretty"
    {
      "snapshot" : {
        "snapshot" : "snapshot_test",
        "uuid" : "LvR3VmNES2CVUii8eAPi7Q",
        "version_id" : 7130399,
        "version" : "7.13.3",
        "indices" : [
          "test"
        ],
        "data_streams" : [ ],
        "include_global_state" : true,
        "state" : "SUCCESS",
        "start_time" : "2021-07-18T13:09:57.575Z",
        "start_time_in_millis" : 1626613797575,
        "end_time" : "2021-07-18T13:09:57.575Z",
        "end_time_in_millis" : 1626613797575,
        "duration_in_millis" : 0,
        "failures" : [ ],
        "shards" : {
          "total" : 1,
          "failed" : 0,
          "successful" : 1
        },
        "feature_states" : [ ]
      }
    }

Список файлов со снапшотами:

    [elasticsearch@2731d1bb9398 bin]$ ls -l /usr/elastic/elasticsearch-7.13.3/snapshots/netology_backup_location/
    total 44
    -rw-r--r-- 1 elasticsearch elasticsearch   508 Jul 18 13:09 index-0
    -rw-r--r-- 1 elasticsearch elasticsearch     8 Jul 18 13:09 index.latest
    drwxr-xr-x 3 elasticsearch elasticsearch  4096 Jul 18 13:09 indices
    -rw-r--r-- 1 elasticsearch elasticsearch 25650 Jul 18 13:09 meta-LvR3VmNES2CVUii8eAPi7Q.dat
    -rw-r--r-- 1 elasticsearch elasticsearch   363 Jul 18 13:09 snap-LvR3VmNES2CVUii8eAPi7Q.dat

Удаление индекса `test`:

    vagrant@vagrant:~$ curl -X DELETE "localhost:9200/test?pretty"
    {
      "acknowledged" : true
    }

Создание индексе `test-2`:

    vagrant@vagrant:~$ curl -X PUT "localhost:9200/test-2?pretty" -H 'Content-Type: application/json' -d'
    {
    "settings":{
      "number_of_shards": 1,
      "number_of_replicas": 0
      }
    }
    '
    {
      "acknowledged" : true,
      "shards_acknowledged" : true,
      "index" : "test-2"
    }
Список индексов:

    vagrant@vagrant:~$ curl -X GET "localhost:9200/_cat/indices?pretty&v=true"
    health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
    green  open   test-2 K85Iq0z3R-qEaJQ9iAMyFQ   1   0          0            0       208b           208b

Восстановление снапшота:

    vagrant@vagrant:~$ curl -X POST "localhost:9200/_snapshot/netology_backup/snapshot_test/_restore?pretty"
    {
      "accepted" : true
    }

Список индексов после восстановления:
    
    vagrant@vagrant:~$ curl -X GET "localhost:9200/_cat/indices?pretty&v=true"
    health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
    green  open   test-2 K85Iq0z3R-qEaJQ9iAMyFQ   1   0          0            0       208b           208b
    green  open   test   3o7JttZAR8WkXVGCCfNLUQ   1   0          0            0       208b           208b
