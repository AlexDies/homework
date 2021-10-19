## Домашнее задание к занятию "4.3. Языки разметки JSON и YAML"
___
Обязательные задания

**1. Мы выгрузили JSON, который получили через API запрос к нашему сервису:**

        { "info" : "Sample JSON output from our service\t",
            "elements" :[
                { "name" : "first",
                "type" : "server",
                "ip" : 7175 
                },
                { "name" : "second",
                "type" : "proxy",
                "ip : 71.78.22.43
                }
            ]
        }

Нужно найти и исправить все ошибки, которые допускает наш сервис

**Результат:**

    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            },
            { "name" : "second",
            "type" : "proxy",
            "ip" : "71.78.22.43"
            }
        ]
    }

**Добавлена кавычка после ip" и IP-адрес взят в кавчки "71.78.22.43"**

**2. В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. 
   Формат записи JSON по одному сервису: { "имя сервиса" : "его IP"}. Формат записи YAML по одному сервису: - имя сервиса: его IP. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.**

Результат:

    import socket
    import time
    import json
    import yaml
    
    ip_service = {
        "drive.google.com": '',
        'mail.google.com': '',
        'google.com': ''
        }
    while True:
        for name_service, current_ip in ip_service.items():
            check_ip = socket.gethostbyname(name_service)
            time.sleep(1)
            if check_ip != current_ip:
                ip_service[name_service] = check_ip
                with open("tes1.json", 'w') as js_f, open("test.yml", 'w') as ym_f:
                    js_f.write(json.dumps(ip_service, indent=2))
                    ym_f.write(yaml.dump(ip_service))
                print(f'[ERROR] {name_service} IP mismatch: {current_ip} New IP: {check_ip}')
            else:
                print(f'{name_service} - {current_ip}')
    
Добавление в файлы yaml и json сделал в цикле, когда адреса не совпадают, так как только в этом случае будет замена в словаре.

**3. Дополнительное задание (со звездочкой) - необязательно к выполнению**

Так как команды в нашей компании никак не могут прийти к единому мнению о том, какой формат разметки данных использовать: JSON или YAML, нам нужно реализовать парсер из одного формата в другой. Он должен уметь:
    
    - Принимать на вход имя файла   
    - Проверять формат исходного файла. Если файл не json или yml - скрипт должен остановить свою работу
    - Распознавать какой формат данных в файле. Считается, что файлы *.json и *.yml могут быть перепутаны
    - Перекодировать данные из исходного формата во второй доступный (из JSON в YAML, из YAML в JSON)
    - При обнаружении ошибки в исходном файле - указать в стандартном выводе строку с ошибкой синтаксиса и её номер
    - Полученный файл должен иметь имя исходного файла, разница в наименовании обеспечивается разницей расширения файлов

**До конца выполнить не удалось, получился следующий код:**

      import sys
      import json
      import yaml
      import os
      
      js = None
      name_file = sys.argv[1]
      suffix = ('.json', '.yml', '.yaml')
      if name_file.endswith(suffix):
          with open(name_file, 'r+') as js_f, open(name_file, 'r+') as js_d:
              js = yaml.safe_load(js_f)
              try:
                  ds = json.load(js_d)
                  print("Формат файла json, файл будет перекодирован в yaml")
                  js_d.seek(0)
                  js_d.truncate()
                  js_d.write(yaml.dump(ds, indent=2, explicit_start=True))
              except json.decoder.JSONDecodeError:
                  print("Этот файл yml формата, файл будет перекодирован в json")
                  js_f.seek(0)
                  js_f.truncate()
                  js_f.write(json.dumps(js))
          if name_file.endswith('.json'):
              pre, ext = os.path.splitext(name_file)
              os.rename(name_file, pre + ".yaml")
              print("Новый формат файла .yaml")
          elif name_file.endswith('.yaml'):
              pre, ext = os.path.splitext(name_file)
              os.rename(name_file, pre + ".json")
              print("Новый формат файла .json")
      
      else:
          print('Формат файла не json или yaml')
          exit()

**Возникли вопросы:**
1. Не совсем понял, как можно поменять формат файлу? Если использовать внутри конструкции with open,
то будет появляться ошибка в формате: PermissionError: [WinError 32] Процесс не может получить доступ к файлу, так как этот файл занят другим процессом: 'testjs.yaml' -> 'testjs.yaml'

Поэтому вынес в цикл if elif после закрытия констрункции with с файлом. Но в таком случае, непонятно, что внутри файла - перепутанный формат или содержание?

**1.1 Какое условие в таком случае использовать для проверки?**

**1.2 Или в данном случае нельзя использолвать конструкцию with open с файлом, а использовать просто open, закрывать его и менять формат с помощью os.rename?**

2. Также пока не разобрался как спарсить сообщение об ошибках на конкретной строчке и колонке, так как выдает много информации в stdout:

         Traceback (most recent call last):
           File "C:\Users\AlexD\PycharmProjects\python_test\home4.5.py", line 11, in <module>
             js = yaml.safe_load(js_f)
           File "C:\Users\AlexD\PycharmProjects\python_test\venv\lib\site-packages\yaml\__init__.py", line 162, in safe_load
             return load(stream, SafeLoader)
           File "C:\Users\AlexD\PycharmProjects\python_test\venv\lib\site-packages\yaml\__init__.py", line 114, in load
             return loader.get_single_data()
           File "C:\Users\AlexD\PycharmProjects\python_test\venv\lib\site-packages\yaml\constructor.py", line 49, in get_single_data
             node = self.get_single_node()
           File "C:\Users\AlexD\PycharmProjects\python_test\venv\lib\site-packages\yaml\composer.py", line 36, in get_single_node
             document = self.compose_document()
           File "C:\Users\AlexD\PycharmProjects\python_test\venv\lib\site-packages\yaml\composer.py", line 58, in compose_document
             self.get_event()
           File "C:\Users\AlexD\PycharmProjects\python_test\venv\lib\site-packages\yaml\parser.py", line 118, in get_event
             self.current_event = self.state()
           File "C:\Users\AlexD\PycharmProjects\python_test\venv\lib\site-packages\yaml\parser.py", line 193, in parse_document_end
             token = self.peek_token()
           File "C:\Users\AlexD\PycharmProjects\python_test\venv\lib\site-packages\yaml\scanner.py", line 129, in peek_token
             self.fetch_more_tokens()
           File "C:\Users\AlexD\PycharmProjects\python_test\venv\lib\site-packages\yaml\scanner.py", line 223, in fetch_more_tokens
             return self.fetch_value()
           File "C:\Users\AlexD\PycharmProjects\python_test\venv\lib\site-packages\yaml\scanner.py", line 577, in fetch_value
             raise ScannerError(None, None,
         yaml.scanner.ScannerError: mapping values are not allowed here
           in "testjs.json", line 2, column 5

**Как в таком случае стоит "вытащить" строчку in "testjs.json", line 2, column 5 из exept?**
