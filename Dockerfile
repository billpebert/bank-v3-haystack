# We used php-apache:7.2 image from the php dockerhub as base image, it has out-of-the-box configurable and functional
#  Apache webserver running mod_php, which is a great place to start with.
# We'll need a couple of extensions and some access control configuration to make development easier.
FROM php:7.2-apache-stretch

# Install Composer
RUN docker-php-ext-install pdo mysqli pdo_mysql
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    unzip \
    curl

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
# Copy the configuration of apache
COPY vhost.conf /etc/apache2/sites-available/000-default.conf
# Copy the haystack app
COPY . /var/www/html
# Set the correct permission owner for the folder and files
# otherwise you will get permission denied when accesing files
RUN chown -R www-data:www-data /var/www/html

# Install laraval dependencies
RUN composer install  --prefer-dist --no-interaction --optimize-autoloader --no-dev

