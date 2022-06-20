FROM erlang:21.0

#Переопределяем рабочую директорию
WORKDIR /app

#Копирование директории приложения
COPY . .

#Устанавливаем всё необходимое для работы
RUN apt-get update
RUN apt-get install -y vim
RUN apt-get install -y curl
RUN apt-get install -y git
RUN rebar3 upgrade