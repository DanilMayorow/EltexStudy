FROM erlang:21.3

#Переопределяем рабочую директорию
WORKDIR /app

#Копирование директории приложения
COPY ../Docker .

#Устанавливаем всё необходимое для работы
RUN apt-get update
RUN apt-get install -y vim
RUN apt-get install -y curl
RUN apt-get install -y git
RUN apt-get install -y net-tools
RUN apt-get install -y inetutils-ping
RUN rebar3 upgrade