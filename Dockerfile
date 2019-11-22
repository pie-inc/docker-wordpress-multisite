FROM php:7.3-apache

# install the PHP extensions we need
RUN apt-get update \
  && apt-get install -y \
  libjpeg-dev \
  libpng-dev \
  sudo \
  && rm -rf /var/lib/apt/lists/* \
  && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
  && docker-php-ext-install gd mysqli opcache

RUN curl -o /usr/local/bin/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
COPY ./data/wpcli-user.sh /usr/local/bin/wp
RUN chmod +x /usr/local/bin/wp
RUN chmod +x /usr/local/bin/wp-cli.phar

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
  echo 'opcache.memory_consumption=128'; \
  echo 'opcache.interned_strings_buffer=8'; \
  echo 'opcache.max_accelerated_files=4000'; \
  echo 'opcache.revalidate_freq=2'; \
  echo 'opcache.fast_shutdown=1'; \
  echo 'opcache.enable_cli=1'; \
  } > /usr/local/etc/php/conf.d/opcache-recommended.ini


# Adding 404 injection protection
# CVE-2007-0450
RUN { \
  echo 'AllowEncodedSlashes NoDecode'; \
  echo 'ServerSignature Off'; \
  echo 'ServerTokens Prod'; \
  echo 'ErrorDocument 404 "404: The requested resource could not be found."'; \
  echo 'ErrorDocument 403 "403: Access Denied. The requested resource requires authentication."'; \
  } >> /etc/apache2/apache2.conf

RUN a2enmod rewrite expires headers

COPY ./wp-content/ /var/www/html/wp-content/
COPY ./data/uploads.ini /usr/local/etc/php/conf.d/uploads.ini

VOLUME /var/www/html

EXPOSE 80

ENV WORDPRESS_VERSION 5.2.4

RUN set -ex; \
  curl -o wordpress.tar.gz -fSL "https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz"; \
  tar -xzf wordpress.tar.gz -C /usr/src/; \
  rm wordpress.tar.gz; \
  chown -R www-data:www-data /usr/src/wordpress

COPY ./data/multisite.htaccess /usr/src/wordpress/multisite.htaccess
COPY ./data/docker-entrypoint.sh /usr/local/bin/
COPY ./data/cron.conf /etc/crontabs/www-data
RUN chmod 600 /etc/crontabs/www-data

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["apache2-foreground"]
