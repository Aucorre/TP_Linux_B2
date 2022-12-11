FROM ubuntu

RUN apt update -y

RUN apt install -y apache2

RUN mkdir /etc/apache2/logs
EXPOSE 80/tcp
COPY index.html /var/www/html/

COPY apache2.conf /etc/apache2/apache2.conf
CMD [ "/usr/sbin/apache2", "-DFOREGROUND" ]