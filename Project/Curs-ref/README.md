## Что это такое?

Websip - это приложение для совершения звонков. Позволяет вызвать 
абонента по номеру и отправить текстовое сообщение. Переданный 
текст будет преобразован в речь и отправлен абоненту. 

## Как это работает?

При запуске начинает работу веб-сервер по указанном в sys.config 
адресу. Веб-сайт представляет собой HTML страницу с формой из
двух полей: номер телефона и текст. После отправки формы на 
сервер осуществляется попытка установить соединение. Для этого 
используется билиотека nksip. В случае, если абоенент отвечает на 
звонок, ему передается сообщение, синтезированное сервисом Yandex 
SpeechKit. Сообщение имеет ограничение по количеству символов в 
255 единиц.

## Что потребуется для запуска?

Подразумевается, что в наличии имеется Softswitch и SIP-клиент. С 
него и будут осуществляться звонки.

Для запуска требуется скофигурировать файл ***sys.config***:
```
    * webserv_ip - ip адрес веб страницы
    * webserv_port - порт веб страницы
    * pbx_domain - домен SIP клиента (@test.doamin)
    * pbx_ip - ip адрес, на котором работает Softswitch
    * client - логин SIP клиента (sip:100)
    * client_pass - пароль SIP клиента
    * udp_port - UDP порт
    * udp_port_reserve - резервный UDP порт
    * route - прокси (если не требуется приравняйте это поле к pbx_ip)
```

Этот файл находится в корне проекта. Кроме этого необходимы: 
```
    программа ffmpeg
    библиотека libortp-dev
``` 
Установить их можно используя пакетный менеджер apt:

```
    apt install ffmpeg libortp-dev
```

Также необходимо дать права на запуск бинарным файлам voice_client и rebar3.
Для этого в папке проекта выполните следующую команду:

```
    chmod +x rebar3 voice_client
```

Если запуск производится на архитектуре отличной от x86, потребуется
установить [rebar3](https://github.com/erlang/rebar3) и для сборки использовать
именно его. Кроме этого, НЕ для x86 архитектуры, выполните следующие команды:

```
    $ cd c_src && make && cd ..
```

## Запуск

Для сборки проекта используется rebar3,
бинарный файл которого можно найти в корне проекта.

```
    $ ./rebar3 get-deps
    $ ./rebar3 compile
    $ ./rebar3 shell
```
Испытания проводилить с использованием Erlang 20 в системе GNU/
Linux в браузере Google Chrome. В других браузерах возможен 
некорректный парсинг GET/POST запросов. 