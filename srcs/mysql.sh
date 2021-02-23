service mysql start
mysql -e "CREATE USER IF NOT EXISTS 'user42'@'localhost' IDENTIFIED BY 'user42';"
mysql -e "CREATE DATABASE IF NOT EXISTS wordpress;" 
mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'user42'@'localhost' WITH GRANT OPTION;"
mysql -e "FLUSH PRIVILEGES;"