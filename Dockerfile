# Dockerfile
FROM php:8.2-apache

ENV COMPOSER_ALLOW_SUPERUSER=1

EXPOSE 80 8090
WORKDIR /app

# git, unzip & zip are for composer
RUN apt-get update -qq && \
    apt-get install -qy \
    git \
    gnupg \
    unzip \
    zip && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# PHP Extensions
RUN docker-php-ext-install -j$(nproc) opcache pdo_mysql
COPY conf/php.ini /usr/local/etc/php/conf.d/app.ini

# RUN a2enmod ssl && a2ensite default-ssl
# RUN a2enmod ssl && a2enmod rewrite

# Apache
# COPY errors /errors
COPY conf/vhost.conf /etc/apache2/sites-available/000-default.conf
COPY conf/apache.conf /etc/apache2/conf-available/z-app.conf
COPY . ./
# COPY ./conf/ssl/*.pem /etc/apache2/ssl/
    
RUN a2enmod rewrite remoteip && \
    a2enconf z-app