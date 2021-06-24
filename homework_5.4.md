## Домашнее задание к занятию "5.4. Практические навыки работы с Docker"
___
**Задача 1**

В данном задании вы научитесь изменять существующие Dockerfile, адаптируя их под нужный инфраструктурный стек.

Измените базовый образ предложенного Dockerfile на Arch Linux c сохранением его функциональности.

    FROM ubuntu:latest
    
    RUN apt-get update && \
        apt-get install -y software-properties-common && \
        add-apt-repository ppa:vincent-c/ponysay && \
        apt-get update
     
    RUN apt-get install -y ponysay
    
    ENTRYPOINT ["/usr/bin/ponysay"]
    CMD ["Hey, netology”]

Для получения зачета, вам необходимо предоставить:

- Написанный вами Dockerfile 
- Скриншот вывода командной строки после запуска контейнера из вашего базового образа
- Ссылку на образ в вашем хранилище docker-hub
___
**Выполнение ДЗ:**
1. Составлен Dockerfile для ArchLinux:
   
        FROM archlinux:latest
        
        RUN pacman -Sy && \
        pacman -S --noconfirm community/ponysay
        
        ENTRYPOINT ["/usr/bin/ponysay"]
        CMD ["Hey, netology”]
2. Процесс создания образа:
   
   **root@vagrant:/home/vagrant/docker1# docker build -t archlinux1 .**
        
        Sending build context to Docker daemon  2.048kB
        Step 1/4 : FROM archlinux:latest
         ---> 1f90233ad36d
        Step 2/4 : RUN pacman -Sy && pacman -S --noconfirm community/ponysay
         ---> Running in 4d1e6fba99ec
        :: Synchronizing package databases...
         core downloading...
         extra downloading...
         community downloading...
        resolving dependencies...
        looking for conflicting packages...
        
        Packages (4) gdbm-1.19-2  libnsl-1.3.0-2  python-3.9.5-3  ponysay-3.0.3-4
        
        Total Download Size:   29.57 MiB
        Total Installed Size:  87.61 MiB
        
        :: Proceed with installation? [Y/n]
        :: Retrieving packages...
         gdbm-1.19-2-x86_64 downloading...
         libnsl-1.3.0-2-x86_64 downloading...
         python-3.9.5-3-x86_64 downloading...
         ponysay-3.0.3-4-any downloading...
        checking keyring...
        checking package integrity...
        loading package files...
        checking for file conflicts...
        :: Processing package changes...
        installing gdbm...
        installing libnsl...
        installing python...
        Optional dependencies for python
            python-setuptools
            python-pip
            sqlite [installed]
            mpdecimal: for decimal
            xz: for lzma [installed]
            tk: for tkinter
        installing ponysay...
        :: Running post-transaction hooks...
        (1/1) Arming ConditionNeedsUpdate...
        Removing intermediate container 4d1e6fba99ec
         ---> dee9cf83ffb1
        Step 3/4 : ENTRYPOINT ["/usr/bin/ponysay"]
         ---> Running in fa9ab01402ba
        Removing intermediate container fa9ab01402ba
         ---> 7d3401779033
        Step 4/4 : CMD ["Hey, netology”]
         ---> Running in 7d66f938fba2
        Removing intermediate container 7d66f938fba2
         ---> b574d6e4ee4f
        Successfully built b574d6e4ee4f
        Successfully tagged archlinux1:latest

**2. Создание контейнера и вывод в интерактивный режим:**

**root@vagrant:/home/vagrant/docker1# docker run -ti archlinux1**

    
             ___________________________
            < /bin/sh ["Hey, netology”] >
             ---------------------------
              \
               \
                \
                 \         ▄█
                 ▄▄▄▄▄▄▄▄▄███▄▄█▀
              ▄█▄▄████████▄▄▄▄▄▄
            ▄▄█▄▄█▄█████▄███▄▄███
            ▀▄█▄▄▄████▄▄▄█▄▄▄▄███
              ▀ ▄▄▄▄▄▄███▄▄▄▄████
               ███▄▄▄████▄██████
               ████▄█▄▄██▄███▄▀
             █▄▄██▄▄▄▄█▄██▄█▀         ▄▄▄
             ▀▄███████▄███▄▄▄▄      ▄▄██▄▄▄
               ▀▀█▄▄▄▄█████▄▀      ███▄████▄▄
                     ██████▄▀ ▄▄▄▄█████▄██████
                     ▀▄███▄▄▄▄█▄██▄▄▀████▄████
                      ██████████▄█▄█  ▀▄█ ██▄▀
                       █▄██▄████▄▄▄▀    ▀ █▀
                       █████▀█▄▄██▄▄
                       █████  ███████
                      ▄▄████  ██████▄▄
                     ▄▄█████  ████████
                    ▄▄██████ ▄▄██████▄▄
                    ▀█▄█████ ▀▀▀█▄█████
                     ▀▀▀▀▀▀     ▀▀▀▀▀▀
            
3. Ссылка на образ в репозитории DockerHub: 
   
https://hub.docker.com/layers/155570942/alexdies/homework/pony1.0/images/sha256-56a6b32a0539b350b0ff34b6d4869c0bf32a6f31f2a2b15404efc449211a87c6?context=explore&tab=layers

**P/S. При использовании репозитория ppa:vincent-c/ponysay выдает ошибку недоступности IP, но в ArchLinux ponysay встроен в community репозиторий - решил взять оттуда.**

___
**Задача 2**

В данной задаче вы составите несколько разных Dockerfile для проекта Jenkins, опубликуем образ в `dockerhub.io` и посмотрим логи этих контейнеров.

Составьте 2 Dockerfile:

1. Общие моменты:
    - Образ должен запускать Jenkins server

2. Спецификация первого образа:
   
  - Базовый образ - amazoncorreto
  - Присвоить образу тэг `ver1`

3. Спецификация второго образа:
   
 - Базовый образ - ubuntu:latest
 - Присвоить образу тэг `ver2`

4. Cоберите 2 образа по полученным Dockerfile

5. Запустите и проверьте их работоспособность

6. Опубликуйте образы в своём dockerhub.io хранилище

Для получения зачета, вам необходимо предоставить:

- Наполнения 2х Dockerfile из задания
- Скриншоты логов запущенных вами контейнеров (из командной строки)
- Скриншоты веб-интерфейса Jenkins запущенных вами контейнеров (достаточно 1 скриншота на контейнер)
- Ссылки на образы в вашем хранилище docker-hub
___
**Выполнение ДЗ:**



___
**Задача 3**

В данном задании вы научитесь:

- объединять контейнеры в единую сеть
- исполнять команды "изнутри" контейнера

Для выполнения задания вам нужно:

1.    Написать Dockerfile:
        - Использовать образ https://hub.docker.com/_/node как базовый
        - Установить необходимые зависимые библиотеки для запуска npm приложения https://github.com/simplicitesoftware/nodejs-demo
        - Выставить у приложения (и контейнера) порт 3000 для прослушки входящих запросов
        - Соберите образ и запустите контейнер в фоновом режиме с публикацией порта

2.    Запустить второй контейнер из образа ubuntu:latest

3.    Создать `docker network` и добавьте в нее оба запущенных контейнера

4.    Используя `docker exec` запустить командную строку контейнера `ubuntu` в интерактивном режиме

5.    Используя утилиту `curl `вызвать путь` /` контейнера с npm приложением

Для получения зачета, вам необходимо предоставить:

- Наполнение Dockerfile с npm приложением
- Скриншот вывода вызова команды списка docker сетей (docker network cli)
- Скриншот вызова утилиты curl с успешным ответом
___
**Выполнение ДЗ:**


