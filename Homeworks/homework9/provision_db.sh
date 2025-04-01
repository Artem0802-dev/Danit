#!/bin/bash

# Update system and install MySQL
sudo apt-get update
sudo apt-get install -y mysql-server

# Configure MySQL to listen on private network
sudo sed -i "s/127.0.0.1/0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

# Restart MySQL
sudo systemctl restart mysql

# Secure MySQL installation
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';"

# Create database and user
sudo mysql -uroot -proot -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
sudo mysql -uroot -proot -e "CREATE USER '$DB_USER'@'192.168.56.%' IDENTIFIED BY '$DB_PASS';"
sudo mysql -uroot -proot -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'192.168.56.%';"
sudo mysql -uroot -proot -e "FLUSH PRIVILEGES;"

# Configure firewall (if enabled)
sudo ufw allow from 192.168.56.0/24 to any port 3306