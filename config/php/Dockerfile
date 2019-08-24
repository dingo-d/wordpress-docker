FROM php:7.3-fpm-stretch

# PHP Extensions
RUN apt-get update && apt-get install -y \
      gnupg \
      libfreetype6-dev \
      libjpeg62-turbo-dev \
      libmcrypt-dev \
      libpng-dev \
      libzip-dev \
      unzip \
      mariadb-client \
      libmagickwand-dev \
    && docker-php-ext-configure gd --with-png-dir=/usr/include/ --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) \
      bcmath \
      exif \
      gd \
      mysqli \
      opcache \
      zip \
      pdo \
      pdo_mysql \
      mysqli \
    && docker-php-ext-install -j$(nproc) iconv \
    && export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" \
    && rm -rf /var/lib/apt/lists/* \
    && pecl install imagick-3.4.4 \
    && pecl install pcov \
    && docker-php-ext-enable imagick

# Composer
RUN curl -sS https://getcomposer.org/installer | php \
  && chmod +x composer.phar && mv composer.phar /usr/local/bin/composer

# Node
RUN curl -sL https://deb.nodesource.com/setup_11.x | bash - && \
    apt-get install -yq nodejs build-essential

# WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
  && php wp-cli.phar --info --allow-root \
  && chmod +x wp-cli.phar \
  && mv wp-cli.phar /usr/local/bin/wp

# No content WordPress
ADD https://downloads.wordpress.org/release/wordpress-5.2.2-no-content.zip /var/www/latest.zip
RUN cd /var/www && unzip latest.zip && rm latest.zip
RUN rm -rf /var/www/html
RUN mkdir -p /var/www/html \
    && mv /var/www/wordpress/* /var/www/html/
RUN chown www-data:www-data /var/www/html/ -R

WORKDIR /var/www/html/

CMD ["php-fpm"]
