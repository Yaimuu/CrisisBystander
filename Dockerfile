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
    zlib1g-dev libpng-dev libjpeg-dev libx11-dev libfreetype6-dev \
    zip && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# PHP Extensions
RUN docker-php-ext-install -j$(nproc) opcache pdo_mysql
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
COPY conf/php.ini /usr/local/etc/php/conf.d/app.ini

# Apache configuration
COPY conf/vhost.conf /etc/apache2/sites-available/000-default.conf
COPY conf/apache.conf /etc/apache2/conf-available/z-app.conf

# Enable necessary Apache modules and configure virtual hosts
RUN a2enmod rewrite remoteip && \
    a2enconf z-app

# Build the container
COPY . ./

# CMD bash -c "chmod +x start.sh & ./start.sh"