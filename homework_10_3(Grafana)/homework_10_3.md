# Домашнее задание к занятию "10.03. Grafana"

## Задание повышенной сложности

**В части задания 1** не используйте директорию [help](./help) для сборки проекта, самостоятельно разверните grafana, где в 
роли источника данных будет выступать prometheus, а сборщиком данных node-exporter:
- grafana
- prometheus-server
- prometheus node-exporter

За дополнительными материалами, вы можете обратиться в официальную документацию grafana и prometheus.

В решении к домашнему заданию приведите также все конфигурации/скрипты/манифесты, которые вы 
использовали в процессе решения задания.

**В части задания 3** вы должны самостоятельно завести удобный для вас канал нотификации, например Telegram или Email
и отправить туда тестовые события.

В решении приведите скриншоты тестовых событий из каналов нотификаций.

## Обязательные задания

### Задание 1
Используя директорию [help](./help) внутри данного домашнего задания - запустите связку prometheus-grafana.

Зайдите в веб-интерфейс графана, используя авторизационные данные, указанные в манифесте docker-compose.

Подключите поднятый вами prometheus как источник данных.

Решение домашнего задания - скриншот веб-интерфейса grafana со списком подключенных Datasource.

## Задание 2
Изучите самостоятельно ресурсы:
- [promql-for-humans](https://timber.io/blog/promql-for-humans/#cpu-usage-by-instance)
- [understanding prometheus cpu metrics](https://www.robustperception.io/understanding-machine-cpu-usage)

Создайте Dashboard и в ней создайте следующие Panels:
- Утилизация CPU для nodeexporter (в процентах, 100-idle)
- CPULA 1/5/15
- Количество свободной оперативной памяти
- Количество места на файловой системе

Для решения данного ДЗ приведите promql запросы для выдачи этих метрик, а также скриншот получившейся Dashboard.

## Задание 3
Создайте для каждой Dashboard подходящее правило alert (можно обратиться к первой лекции в блоке "Мониторинг").

Для решения ДЗ - приведите скриншот вашей итоговой Dashboard.

## Задание 4
Сохраните ваш Dashboard.

Для этого перейдите в настройки Dashboard, выберите в боковом меню "JSON MODEL".

Далее скопируйте отображаемое json-содержимое в отдельный файл и сохраните его.

В решении задания - приведите листинг этого файла.

___
## Выполнение ДЗ:
### Задание 1

С помощью `docker-compose -d up` поднят необходимый стек.

Вход на WEB-интерфейс `Grafana` `localhost:3000` по паролю и логину `admin/admin` успешен.

![Screenshot](grafana.jpg)

В `Confiuration` ->` Data Sources` выбран источник данных `Prometheus`:
URL: http://localhost:9090
Access: Browser
Name: Prometheus

![Screenshot](addprom.jpg)
## Задание 2

Создан новый Dashboard и добавлены следующие Panels:

Привязка идет к `job = nodeexporter`

- Утилизация CPU для nodeexporter:
  
`100 -(avg by (instance) (rate(node_cpu_seconds_total{job="nodeexporter",mode="idle"}[1m])) * 100)`
- CPULA 1/5/15

Добавим 3 Query:

`node_load1`

`node_load5`

`node_load15`

- Количество свободной оперативной памяти:
  
`node_memory_Inactive_bytes/node_memory_MemAvailable_bytes*100`

- Количество места на файловой системе:
  
`node_filesystem_free_bytes{fstype=~"ext4|xfs"} / node_filesystem_size_bytes{fstype=~"ext4|xfs"}*100`

![Screenshot](dashboard.jpg)

## Задание 3

Созданы alet-события на каждую панель Dashboard:

![Screenshot](alert.jpg)
## Задание 4

Файл dashboard.json во вложении
