FROM debian:buster
ARG index=1

RUN apt -y update \
&& apt -y install mariadb-server nginx wget php7.3-fpm php7.3-mysql php7.3-curl php7.3-gd php7.3-intl php7.3-mbstring php7.3-soap php7.3-xml php7.3-xmlrpc  php7.3-zip sendmail

COPY srcs/mysql.sh /
RUN bash mysql.sh

RUN wget https://github.com/FiloSottile/mkcert/releases/download/v1.4.3/mkcert-v1.4.3-linux-amd64 -O mkcert
RUN chmod 755 mkcert && ./mkcert -install && ./mkcert -cert-file /etc/ssl/certs/localhost.pem -key-file /etc/ssl/certs/localhost-key.pem localhost sendmail

RUN mkdir /var/www/localhost

COPY srcs/nginxconf /
COPY srcs/nginxconf_no_index /
COPY srcs/index.sh /
RUN chmod +x /index.sh \
&& /index.sh $index

COPY srcs/wordpress.tar.gz /wordpress.tar.gz
COPY srcs/wp-config.php /
RUN service mysql start \
	&& tar xvzf wordpress.tar.gz -C /var/www/localhost/ --strip-components 1 \
	&& rm wordpress.tar.gz \
	&& cp /wp-config.php /var/www/localhost/

RUN mkdir /var/www/localhost/phpmyadmin
COPY srcs/phpmyadmin.tar.gz /
RUN tar xvzf phpmyadmin.tar.gz -C /var/www/localhost/phpmyadmin --strip-components 1 
COPY srcs/config.inc.php /var/www/localhost/phpmyadmin/config.inc.php
RUN chown -R www-data:www-data /var/www/localhost/

EXPOSE 80 443

COPY srcs/start.sh /

ENTRYPOINT bash start.sh \
&& tail -f /dev/null