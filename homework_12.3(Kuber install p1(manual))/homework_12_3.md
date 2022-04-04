# Домашнее задание к занятию "12.3 Развертывание кластера на собственных серверах, лекция 1"
Поработав с персональным кластером, можно заняться проектами. Вам пришла задача подготовить кластер под новый проект.

## Задание 1: Описать требования к кластеру
Сначала проекту необходимо определить требуемые ресурсы. Известно, что проекту нужны база данных, система кеширования, а само приложение состоит из бекенда и фронтенда. Опишите, какие ресурсы нужны, если известно:

* база данных должна быть отказоустойчивой (не менее трех копий, master-slave) и потребляет около 4 ГБ ОЗУ в работе;
* кэш должен быть аналогично отказоустойчивый, более трех копий, потребление: 4 ГБ ОЗУ, 1 ядро;
* фронтенд обрабатывает внешние запросы быстро, отдавая статику: не более 50 МБ ОЗУ на каждый экземпляр;
* бекенду требуется больше: порядка 600 МБ ОЗУ и по 1 ядру на копию.

Требования: опишите, сколько нод в кластере и сколько ресурсов (ядра, ОЗУ, диск) нужно для запуска приложения. Расчет вести из необходимости запуска 5 копий фронтенда и 10 копий бекенда, база и кеш.

___
## Выполнение ДЗ:
## Задача 1: Описать требования к кластеру

Составим таблицу потребления ресурсов:

|Ресурсы|CPU|RAM|Количество|Коэффицент запаса|Итогое количество необходимых ресурсов|
|:---|:---|:---|:---|:---|:---|
|Data Base|1 ядро|4 Гб|x3|1.2|округляем до 4 и округляем до 15 Гб|
|Кэш|1 ядро|4 Гб|x3|1.2|округляем до 4 и округляем до 15 Гб|
|Fronend|0.1 ядра|50 Мб|x5|1.2|округляем до 1 ядра и округляем до 1 Гб|
|Backend|1 ядро|600 Мб|x10|1.2|12 ядер и округляем до 8Гб|
|Рабочая нода|1 ядро|1 Гб|x1|1.2|округляем до 2 ядер и до 2 Гб|
|Управляющая нода|2 ядра|2 Гб|x1|1.2|округляем до 3 ядер и округляем до 3 Гб|

**Общее количевство:**

На весь проект (ПО) = 21 CPU и 39 Гб  RAM

Рабочие ноды (минимум 3 шт) = 6 CPU и 6 Гб RAM

ПО + Рабочие ноды = 27 CPU и 45 Гб RAM

Управаляющие ноды - берем 3 шт. (нечетное количество) = 9 CPU и 9 Гб RAM

**Итог:**

**Рабочие ноды:** Берем в расчет минимум 3 шт. рабочие ноды для повышения отказоустойчивости и получаем, что на одну рабочую ноду необходимо 9 CPU и 15 Гб RAM. Как альтернатива, можно рассмотреть стоимость одной ноды из расчета 5 шт рабочих нод - т.е. с характеристиками равными 6 CPU (округление в большую сторону) и 9 Гб RAM.

По дисковому пространству - нам неизвестно пока что это за проект и насколько "жирная" будет БД, но пока ориенируемся на стандартное значение дискового пространства равному 100 Гб на одну ноду. При необходимости увеличить.

**Управляющие ноды:** Оставляем их количество равным 3 шт. Соответственно, параметры каждой ноды будут равными 9 CPU и 9 Гб RAM.

По дисковому пространству - думаю, что стандартных 50 Гб вполне хватит на одну ноду.