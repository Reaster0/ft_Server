FROM debian:buster
# MAINTAINER Evan_Arnaud <earnaud@student.com>

RUN apt -y update \
&& apt -y upgrade \
&& apt -y install nginx
# RUN apt -y install default-mysql-server
RUN apt -y install mariadb-server
RUN apt -y install wget
# RUN apt -y install php-cgi php php-mysql php-fpm php-cli php-mbstring php-zip php-gd
RUN apt install -y php7.3-fpm php7.3-mysql php7.3-curl php7.3-gd php7.3-intl php7.3-mbstring php7.3-soap php7.3-xml php7.3-xmlrpc  php7.3-zip 

#mysql
COPY srcs/mysql.sh /
RUN bash mysql.sh

# RUN service mysql start \
# 	&& mysql -e "CREATE USER IF NOT EXISTS '$user'@'localhost' IDENTIFIED BY '$password';" \
# 	&& mysql -e "CREATE DATABASE IF NOT EXISTS $database;" \
# 	&& mysql -e "GRANT ALL PRIVILEGES ON $database.* TO '$user'@'localhost' WITH GRANT OPTION;" \
# 	&& mysql -e "FLUSH PRIVILEGES;"

# mkcert
RUN wget https://github.com/FiloSottile/mkcert/releases/download/v1.4.3/mkcert-v1.4.3-linux-amd64 -O mkcert
RUN chmod 755 mkcert && ./mkcert -install && ./mkcert -cert-file /etc/ssl/certs/localhost.pem -key-file /etc/ssl/certs/localhost-key.pem localhost
# RUN openssl req -x509 -nodes -days 365 -subj "/C=FR/ST=Paris/L=Paris/O=42 School/OU=earnaud/CN=localhost" -newkey rsa:2048 -keyout /etc/ssl/nginx-selfsigned.key -out /etc/ssl/nginx-selfsigned.crt;


RUN mkdir /var/www/localhost

# nginx
# RUN service nginx start
COPY srcs/nginxconf srcs/nginxconf_no_index srcs/indexon srcs/indexoff /
RUN cp /nginxconf /etc/nginx/sites-available/localhost
RUN ln -s /etc/nginx/sites-available/localhost /etc/nginx/sites-enabled/


# wordpress
COPY srcs/wordpress.tar.gz /
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && service mysql start \
	&& tar xvzf wordpress.tar.gz -C /var/www/localhost/ --strip-components 1 \
	&& rm wordpress.tar.gz \
	&& chmod +x wp-cli.phar \
	&& /wp-cli.phar config create --path=/var/www/localhost --dbname=wordpress --dbuser=user42 --dbpass=user42 --allow-root \
	&& /wp-cli.phar core install --path=/var/www/localhost --url=localhost --title="ft_server" --admin_user=admin --admin_password=admin --admin_email=admin@localhost.com --allow-root

# myphpadmin
RUN mkdir /var/www/localhost/phpmyadmin
COPY srcs/phpmyadmin.tar.gz /

RUN tar xvzf phpmyadmin.tar.gz -C /var/www/localhost/phpmyadmin --strip-components 1 
COPY srcs/config.inc.php /var/www/localhost/phpmyadmin/
RUN chown -R www-data:www-data /var/www/localhost/

EXPOSE 80 443

COPY srcs/start.sh /
ENTRYPOINT bash start.sh \
&& tail -f /dev/null