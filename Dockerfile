# Operating system
FROM debian:buster

# Update directory and install services
RUN apt-get update && apt-get -y install \
	nginx \
	wget \
	php7.3-fpm php-mysql php-mbstring php-zip php-gd \
	mariadb-server \
	sendmail

# Configure nginx
COPY ./srcs/nginx.conf /etc/nginx/sites-available/
RUN ln -s /etc/nginx/sites-available/nginx.conf /etc/nginx/sites-enabled/nginx.conf

# Add certificate and key
COPY ./srcs/domain.crt ./srcs/domain.key /etc/ssl/certs/

# Install and configure phpmyadmin
RUN wget https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-english.tar.gz
RUN tar xf phpMyAdmin-5.0.2-english.tar.gz -C /var/www/html/ && rm phpMyAdmin-5.0.2-english.tar.gz
RUN mv /var/www/html/phpMyAdmin-5.0.2-english/ /var/www/html/phpmyadmin/
COPY ./srcs/config.inc.php /var/www/html/phpmyadmin/

# Increase maximum file size
RUN sed -i '/upload_max_filesize/c upload_max_filesize = 20M' /etc/php/7.3/fpm/php.ini
RUN sed -i '/post_max_size/c post_max_size = 20M' /etc/php/7.3/fpm/php.ini

# Configure database
COPY ./srcs/configuration.sql /var/
RUN service mysql start && \
	mysql -u root mysql < /var/www/html/phpmyadmin/sql/create_tables.sql && \
	mysql -u root mysql < /var/configuration.sql

# Install wordpress command line interface (CLI), install wordpress and configure wordpress
RUN mkdir /var/www/html/wordpress/
COPY ./srcs/wp-config.php /var/www/html/wordpress/
RUN wget -O /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x /usr/local/bin/wp
RUN wp cli update
RUN wp core download --allow-root --path=/var/www/html/wordpress/
RUN service mysql start && \
	wp core install --allow-root --path=/var/www/html/wordpress/ --url=https://localhost/wordpress --title=INeedCoffee --admin_user=Tessa --admin_password=coffee --admin_email=tessa.vanderloo@outlook.com

# Grant ownership to nginx user and set permissions
RUN chown -R www-data:www-data /var/www
RUN chmod 755 -R /var/www

# Expose port 80(default, HTTP) and 443(HTTPS)
EXPOSE 80 443

# Start services in the container
CMD service nginx start && \
	service php7.3-fpm start &&\
	service mysql start && \
	service sendmail start && \
	tail -f /dev/null

# Build container: 
#	docker build . -t server

# Run container in detached mode:
#	docker run --rm --name server -p 80:80 -p443:443 -d server

# To interact with the container
#	docker exec -it server bash

# Turn autoindex off: 
#	cd /etc/nginx/sites-available/ && sed -i 's/autoindex on/autoindex off/g' nginx.conf
#	service nginx restart

# View, stop and remove containers
#	docker ps
#	docker kill server
#	docker system prune -a 
