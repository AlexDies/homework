## Домашнее задание к занятию "5.2. Системы управления виртуализацией"
___
**Задача 1**

Выберете подходящую систему управления виртуализацией для предложенного сценария. Детально опишите ваш выбор.

Сценарии:

    - 100 виртуальных машин на базе Linux и Windows, общие задачи, нет особых требований:
    
    Подойдут системы VirtualBox или же VMware Workstation, так как особых требований не выдвигается.
    
    - Преимущественно Windows based инфраструктура, требуется реализация программных балансировщиков нагрузки, репликации данных и автоматизированного механизма создания резервных копий 
    
    Подойдёт Hyper-V, так как это преимущественно Windows based система виртуализации.
    
    - Требуется наиболее производительное бесплатное opensource решение для виртуализации небольшой (20 серверов) инфраструктуры Linux и Windows виртуальных машин 
    
    Подойдёт система KVM. За счет того, что она opensource, а также работает стабильнее с windows машинами, чем xen 
    
    - Необходимо бесплатное, максимально совместимое и производительное решение для виртуализации Windows инфраструктуры
      
    Подойдёт система KVM. За счет того, что она opensource, а также работает стабильнее с windows машинами, чем xen 
    
    - Необходимо рабочее окружение для тестирования программного продукта на нескольких дистрибутивах Linux
    
    Подойдёт система xen, за счет того, что имеет лучшую работу драйвера с Linux-системами, в отличие от KVM

**P/S. Если есть какие-то замечания или дополнения, то прошу дать обратную связь, плотно со всеми системами управления виртуализацией ранее не работал.**
___
### Доработка Задания 1:

     - 100 виртуальных машин на базе Linux и Windows, общие задачи, нет особых требований
    
    Для более легкого развертывания и управления машинами, можно воспользоваться Vagrant с привязкой к какой-либо системе виртуализации, например VirtualBox.
    Это позволдит "поднимать" большое количество машин и управлять ими буквально парой команд
    
     - Необходимо рабочее окружение для тестирования программного продукта на нескольких дистрибутивах Linux
    
    Соглашусь, что в рамках тестирования жизненный цикл виртуальной машины небольшой и правильнее будет использовать контейнер. Например, Docker.

**P/S. Если есть замечания, то прошу дать обратную связь, возможно в реалиях есть более подходящие системы под эти задачи.**
___
**Задача 2**

Опишите сценарий миграции с VMware vSphere на Hyper-V для Linux и Windows виртуальных машин. 
Детально опишите необходимые шаги для использования всех преимуществ Hyper-V для Windows.

2.1 **К сожалению, информации довольно много и она разная для конкретного ответа на данный вопрос. Возникли некоторые трудности.**

1. Если речь идёт о миграции, то нам главное преобразовать образ жесткого диска с VMDK в VHD(VHDX) используя специализированную утилиту. Например, Convert-WindowsImage или vhdtool.exe
2. Загрузить данный образ жесткого диска в новую созданную машину на Hyper-V

2.2 **Каких-то особых отличий при переносе Linux и Windows виртуальных машин не нашел. Прошу помочь с ответом на данный вопрос.**

2.3 **Касательно описания шагов для использования всех преимуществ Hyper-V для Windows, то также не совсем понятным остался данный вопрос. Необходимо описать последовательность действий в настройках Hyper-V для Windows? Или что необходимо сделать?**

Прошу помочь с ответом на возникшие вопросы.
___
### Доработка Задания 2:
Варианты переноса могут разные, в зависимости от инфраструктуры, которая реализована.

Если используется System Center Virtual Machine Manager, то можно воспользоваться средствами переноса данной системы:
1. Добавить узел VMware в System Center VMM
2. В System Center VMM перейти в раздел "Преобразовать виртуальную машину"
3. Выбрать машину VMware которую необходимо преобразовать как источник.
4. Сконфигурировать виртуальную машину - указать количество памяти и число процессоров
5. При необходимости сконфигурировать сеть
6. Нажать "Создать" для преобразования.
7. Запускаем готовую виртуальную машину

Если нет System Center Virtual Machine Manager, то можно поступить следующим образом:
1. В VMWare преобразовать виртуальную машину в формат  Open Virtualization Format (OVF)
2. Использовать специальную утилиту для преобразования образа, например  StarWind V2V Converter.
Это позволит преобразовать формат OVF(включающий в себя VMDK) в формат VHD(VHDX) для Hyper-V.
3. Создаем новую виртуальную машину в Hyper-V
4. Указываем образ жесткого диска наш сформированный ранее формат VHD(VHDX)
5. Выделим аналогичные настройки ресурсов, что и были ранее для VMware
6. Создаем новую виртуальную машину и запускаем её

**P/S. Попробовал описать два варианты миграции. Также в задании указано касательно миграции Linux и Windows-машин, но в целом - алгоритм же остается такой-же. Или есть какие-то нюансы?**
___
**Задача 3**

Опишите возможные проблемы и недостатки гетерогенной среды виртуализации (использования нескольких систем управления виртуализацией одновременно) и что необходимо сделать для минимизации этих рисков и проблем. 
Если бы у вас был бы выбор, то создавали ли вы бы гетерогенную среду или нет? Мотивируйте ваш ответ примерами.

К сожалению, не нашел какого-либо развернутого описания проблем при использовании нескольких систем управления виртуализацией одновременно. 

**3.1 И сам вопрос пока остался не до конца понятным.
То есть смысл заключается в том, чтобы поставить несколько систем управления виртуализацией одновременно на одном железе?** 

**3.2 А как в таком случаек можно поставить одновременно две системы виртуализации аппаратного уровня? Например, KVM и VMWare vSphere?**

**3.3 А вообще, используют ли в реальных кейс такое? На ум пришло только использования какого-нибудь KVM и внутри развернуть уже docker(но это на уровне ОС виртуализация)**

Отвечая на вопрос, предполагаю следующее:

- В голову приходит возможная конфликтность между ОС, с которыми планируется дальнейшая работа, так как может возникнуть конфликт драйверов гипервизоров у систем виртуализации. 
Например, конфликт в работе VirtualBox и Hyper-V (при включенной виртуализации Hyper-V в системе Windows, VirtualBox работал некорректно)
- А также вижу как недостаток несколько уровней доступа виртуальной ОС к аппаратному железу (сначала первый гипервизор, затем второй)

Если бы был выбор, то исходя из проблем выше - конечно же нет, не использовать. Лучше использовать для каждой задачи свою предпочтительную систему виртуализации.

___
### Доработка Задания 3:

Если речь идёт об использовании разных систем управления виртуализацией одновременно, на разных ПК. То я вижу следующие нюансы и риски:
1. Необходимость мониторинга каждой системы виртуализации в отдельности
2. Необходимость бэкапить виртуальные машины в каждой системе управления по-разному. А также возможное отсутствие автоматических бэкапов.
3. Проблемы с переносом виртуальных машин между разными системами управления виртуализей, например, между Hyper-V и VMWare (разный формат машин)
4. Различие в интерфейсах управления и настройке каждой системы управления виртуализацией.
5. Из пункта выше следует дополнительное обучение персонала каждому используемому виду управления виртуализации.
6. Возможно часть виртуальных машин будет создана на системах виртуализации, не обеспечивающих максимальный профи от железа. (например, установка windows based систем на VirtualBox, вместо Hyper-V)

То есть в конечном итоге приходим к тому, что лучше всего иметь одну виртуальную среду под определенные задачи. Кроме ситуаций, где попросту не остается вариантов, как установить ещё одну. Но в таком случае, если система универсальна, то стоит перенести все виртаульынке машины на неё.


**P/S. Если есть ещё что-то добавить, то прошу помочь и пояснить. Если где-то ошибся - также прошу поправить.**