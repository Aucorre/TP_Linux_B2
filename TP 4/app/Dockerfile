FROM ubuntu

RUN apt update -y

RUN apt install -y tar curl
RUN curl -O https://dl.google.com/go/go1.19.3.linux-amd64.tar.gz

RUN tar -C /usr/local -xzf go1.19.3.linux-amd64.tar.gz
RUN mkdir app
COPY hangman-web app

WORKDIR app

RUN /usr/local/go/bin/go build server/main.go
CMD [ "/usr/local/go/bin/go run server/main.go" ]

EXPOSE 8080/tcp