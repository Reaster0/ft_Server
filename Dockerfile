FROM debian:buster
MAINTAINER Evan_Arnaud <earnaud@student.com>

RUN apt -y update
RUN apt -y upgrade
RUN apt -y install nginx
RUN apt -y install default-mysql-server
# RUN apt -y install mariadb-server
RUN apt -y install php-cgi php php-mysql php-fpm php-cli php-mbstring php-zip php-gd
EXPOSE 80 443

RUN mkdir var/www/ft_server

COPY srcs/mkcert-v1.4.3-linux-amd64 /usr/local/bin/mkcert
RUN chmod +x /usr/local/bin/mkcert
RUN mkcert -install

RUN mkdir /var/html/phpmyadmin/tempo
COPY srcs/phpMyAdmin-5.0.4-all-languages.tar.gz ./root/
RUN tar -xvf phpMyAdmin-5.0.4-all-languages.tar.gz
RUN mv phpMyAdmin-5.0.4-all-languages /var/html/phpmyadmin

COPY srcs/nginxconf /etc/nginx/sites-available/
COPY srcs/info.php /var/www/ft_server/info.php

COPY srcs/wordpress-5.6.1.tar.gz ./root
RUN tar -xvf wordpress-5.6.1.tar.gz
RUN mv wordpress-5.6.1 /var/www/ft_server/wordpress

RUN ln -s /etc/nginx/sites-available/nginxconf /etc/nginx/sites-enabled/

RUN mkcert localhost
RUN mv localhost.pem /etc/nginx/
RUN mv localhost-key.pem /etc/nginx/

RUN service nginx restart
RUN service mysql restart
RUN service php7.3-fpm start
RUN tail -f /dev/null