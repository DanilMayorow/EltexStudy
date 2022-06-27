FROM erlang:21.3

#Переопределяем рабочую директорию
WORKDIR /app

#Копирование директории приложения
COPY ../../../Personal/ex7 .

#Выедляем порт под web-интерфейс
EXPOSE 8080

#Устанавливаем всё необходимое для работы
RUN apt-get update
RUN apt-get install -y vim curl
RUN apt-get install -y git
RUN apt-get install -y net-tools inetutils-ping
RUN apt-get install -y ffmpeg libortp-dev
RUN chmod +x rebar3 voice_client
RUN rebar3 upgrade