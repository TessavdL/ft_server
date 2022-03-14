CREATE DATABASE wordpress_db;
GRANT ALL PRIVILEGES ON wordpress_db.* TO 'root'@'localhost' WITH GRANT OPTION;
GRANT SELECT, INSERT, UPDATE, DELETE ON phpmyadmin.* TO 'root'@'localhost';
FLUSH PRIVILEGES;
update mysql.user set plugin = 'mysql_native_password' where user ='root';
EXIT