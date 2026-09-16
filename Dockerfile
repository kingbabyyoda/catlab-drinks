ARG NODE_VERSION=22

FROM php:8.1-apache

ENV APACHE_DOCUMENT_ROOT=/var/www/html/public

RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    default-mysql-client \
    libicu-dev \
    libzip-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libonig-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" mysqli pdo_mysql bcmath zip intl gd \
    && a2enmod rewrite headers \
    && rm -rf /var/lib/apt/lists/*

# Install Composer without using thecodingmachine image (whose entrypoint
# invokes sudo, which Render blocks with no-new-privileges).
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Install Node.js 22 for the frontend build.
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get update \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/sites-available/*.conf \
    /etc/apache2/apache2.conf \
    /etc/apache2/conf-available/*.conf

WORKDIR /var/www/html
COPY . /var/www/html

RUN composer install --no-interaction --prefer-dist --optimize-autoloader \
    && npm install \
    && npm run prod \
    && chown -R www-data:www-data /var/www/html

USER root
ENTRYPOINT ["/usr/local/bin/render-entrypoint.sh"]
CMD ["apache2-foreground"]

COPY docker/render-entrypoint.sh /usr/local/bin/render-entrypoint.sh
RUN chmod +x /usr/local/bin/render-entrypoint.sh
