FROM debian:buster
MAINTAINER Evan_Arnaud <earnaud@student.com>

RUN apt -y update
RUN apt -y upgrade
RUN apt -y install nginx
RUN apt -y install default-mysql-server
RUN apt -y install wget
RUN apt -y install php-cgi php php-mysql php-fpm php-cli php-mbstring php-zip php-gd

# mkcert
RUN wget https://github.com/FiloSottile/mkcert/releases/download/v1.4.3/mkcert-v1.4.3-linux-amd64 -O mkcert
# COPY srcs/mkcert-v1.4.3-linux-amd64 /mkcert
RUN chmod 755 mkcert && ./mkcert -install && ./mkcert localhost
# RUN openssl req -x509 -nodes -days 365 -subj "/C=FR/ST=Paris/L=Paris/O=42 School/OU=earnaud/CN=localhost" -newkey rsa:2048 -keyout /etc/ssl/nginx-selfsigned.key -out /etc/ssl/nginx-selfsigned.crt;

RUN mkdir /var/www/localhost

# myphpadmin
RUN mkdir -p /var/lib/phpmyadmin/temp && mkdir /var/www/localhost/phpmyadmin
COPY srcs/phpMyAdmin-5.0.4-all-languages.tar.gz /
RUN tar -xvf phpMyAdmin-5.0.4-all-languages.tar.gz
RUN mv phpMyAdmin-5.0.4-all-languages /var/www/localhost/phpmyadmin
RUN chown -R www-data:www-data /var/lib/phpmyadmin
COPY srcs/config.inc.php /var/www/localhost/phpmyadmin/

# nginx
RUN service nginx start
COPY srcs/nginxconf srcs/nginxconf_no_index srcs/indexon srcs/indexoff /
RUN ./indexon
RUN ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/

# mysql
COPY srcs/wordpress.sql /
COPY srcs/mysql.sh /
RUN bash mysql.sh


COPY srcs/wordpress-5.6.1.tar.gz /
RUN tar -xvf wordpress-5.6.1.tar.gz
RUN cp -r wordpress /var/www/localhost/wordpress
RUN chown -R www-data:www-data /var/www/html /var/www/localhost/
COPY srcs/wp-config.php /var/www/localhost/wordpress/

EXPOSE 80 443

COPY srcs/start.sh /
RUN bash start.sh
CMD bin/sh