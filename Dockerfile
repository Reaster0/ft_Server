FROM debian:buster
MAINTAINER Evan_Arnaud <earnaud@student.com>

RUN apt -y update
RUN apt -y upgrade
RUN apt -y install nginx
RUN apt -y install default-mysql-server
# RUN apt -y install mariadb-server
RUN apt -y install wget
RUN apt -y install php-cgi php php-mysql php-fpm php-cli php-mbstring php-zip php-gd


# RUN mkdir var/www/html/ft_server

COPY srcs/mkcert /
RUN chmod +x mkcert
RUN mv mkcert /usr/local/bin/mkcert
RUN mkcert -install

RUN mkdir -p /var/lib/phpmyadmin/temp
# RUN mkdir /var/www/html/phpmyadmin
COPY srcs/phpMyAdmin-5.0.4-all-languages.tar.gz /
RUN tar -xvf phpMyAdmin-5.0.4-all-languages.tar.gz
RUN mv phpMyAdmin-5.0.4-all-languages /var/www/html/phpmyadmin
RUN chown -R www-data:www-data /var/lib/phpmyadmin

COPY srcs/config.inc.php /var/www/html/phpmyadmin/

RUN service nginx start
COPY srcs/nginxconf /etc/nginx/sites-available/localhost
RUN ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/
RUN rm -f /etc/nginx/sites-enabled/default


# RUN service mysql start
# RUN echo "CREATE DATABASE wordpress DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;" | mysql -u root
# RUN echo "GRANT ALL ON wordpress.* TO 'root'@'localhost';" | mysql -u root
# RUN echo "FLUSH PRIVILEGES;" | mysql -u root
# RUN echo "update mysql.user set plugin = 'mysql_native_password' where user='root';" | mysql -u root
COPY srcs/wordpress.sql /
COPY srcs/mysql.sh /mysql.sh
# RUN mysql wordpress -u root < wordpress.sql
RUN bash mysql.sh


COPY srcs/wordpress-5.6.1.tar.gz /
RUN tar -xvf wordpress-5.6.1.tar.gz
RUN cp -r wordpress /var/www/html/wordpress
RUN chown -R www-data:www-data /var/www/html
COPY srcs/wp-config.php /var/www/html/wordpress/

RUN ln -s /etc/nginx/sites-available/nginxconf /etc/nginx/sites-enabled/

RUN mkcert localhost
RUN mv localhost.pem /etc/nginx/
RUN mv localhost-key.pem /etc/nginx/

EXPOSE 80 443

COPY srcs/start.sh /
RUN bash start.sh
CMD bin/sh

# RUN service nginx restart
# RUN service mysql restart
# RUN service php7.3-fpm start
# RUN tail -f /dev/null