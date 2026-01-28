# Base image met PHP FPM
FROM php:8.2-fpm

# Set working directory
WORKDIR /var/www/html

# --- Install system dependencies ---
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libonig-dev \
    libicu-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    curl \
    npm \
    && docker-php-ext-install calendar intl gd pdo_mysql zip

# --- Install Composer ---
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# --- Copy app files ---
COPY . .

# --- Install PHP dependencies ---
RUN composer install --no-interaction --optimize-autoloader --no-dev

# --- Install Node dependencies & build frontend ---
RUN npm install
RUN npm run build

# --- Set permissions ---
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html/storage /var/www/html/bootstrap/cache

# --- Expose port ---
EXPOSE 9000

# --- Start PHP-FPM ---
CMD ["php-fpm"]
