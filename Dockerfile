# Use PHP 8.3 with Apache on Debian Bullseye
# check=skip=FromPlatformFlagConstDisallowed
FROM --platform=linux/amd64 php:8.3-apache-bullseye

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libpq-dev \
    libicu-dev \
    libzip-dev \
    libonig-dev \
    libxml2-dev \
    default-mysql-client \
    vim \
    wget \
    curl \
    && docker-php-ext-configure gd --with-jpeg \
    && docker-php-ext-install \
        gd \
        mysqli \
        pdo \
        pdo_mysql \
        intl \
        zip \
        mbstring \
        xml \
        bcmath \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache modules
RUN a2enmod rewrite

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/html

# Download Drupal 10.3.0 (stable version compatible with PHP 8.3 and CiviCRM 6.5)
RUN composer create-project drupal/recommended-project:10.3.0 drupal --no-interaction --no-dev \
    && cd drupal \
    && composer require drush/drush --no-interaction

# Set up Drupal settings
RUN cd /var/www/html/drupal/web/sites/default \
    && cp /var/www/html/drupal/web/core/assets/scaffold/files/default.settings.php . \
    && cp default.settings.php settings.php \
    && chmod 666 settings.php \
    && mkdir -p files \
    && chown -R www-data:www-data /var/www/html/drupal

# Create symlinks for Apache
WORKDIR /var/www/html
RUN ln -s drupal/web/* . \
    && ln -s drupal/web/.htaccess .

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/drupal/web/sites/default/files

# Configure PHP for Drupal 10 and CiviCRM
RUN echo "memory_limit = 512M" >> /usr/local/etc/php/conf.d/drupal.ini \
    && echo "max_execution_time = 300" >> /usr/local/etc/php/conf.d/drupal.ini \
    && echo "upload_max_filesize = 64M" >> /usr/local/etc/php/conf.d/drupal.ini \
    && echo "post_max_size = 64M" >> /usr/local/etc/php/conf.d/drupal.ini \
    && echo "max_input_vars = 2000" >> /usr/local/etc/php/conf.d/drupal.ini

# Expose port 80
EXPOSE 80

# Start Apache
CMD ["apache2-foreground"]
