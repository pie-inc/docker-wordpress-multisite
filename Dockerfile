FROM php:7.4-apache

# persistent dependencies
RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
  # Ghostscript is required for rendering PDF previews
  ghostscript \
  ; \
  rm -rf /var/lib/apt/lists/*

# install the PHP extensions we need
RUN set -ex; \
  \
  savedAptMark="$(apt-mark showmanual)"; \
  \
  apt-get update \
  && apt-get install -y --no-install-recommends \
  libfreetype6-dev \
  libjpeg-dev \
  libpng-dev \
  libwebp-dev \
  libzip-dev \
  ; \
  \
  docker-php-ext-configure gd --with-jpeg --with-freetype --with-webp; \
  docker-php-ext-install -j "$(nproc)" gd mysqli zip bcmath exif; \
  \
  # reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
  apt-mark auto '.*' > /dev/null; \
  apt-mark manual $savedAptMark; \
  ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
  | awk '/=>/ { print $3 }' \
  | sort -u \
  | xargs -r dpkg-query -S \
  | cut -d: -f1 \
  | sort -u \
  | xargs -rt apt-mark manual; \
  \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
  rm -rf /var/lib/apt/lists/*

RUN curl -o /usr/local/bin/wp-cli.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
COPY ./data/wpcli-user.sh /usr/local/bin/wp
RUN chmod +x /usr/local/bin/wp
RUN chmod +x /usr/local/bin/wp-cli.phar

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN set -eux; \
  docker-php-ext-enable opcache; \
  { \
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

RUN set -eux; \
  a2enmod rewrite expires headers; \
  \
  # https://httpd.apache.org/docs/2.4/mod/mod_remoteip.html
  a2enmod remoteip; \
  { \
  echo 'RemoteIPHeader X-Forwarded-For'; \
  # these IP ranges are reserved for "private" use and should thus *usually* be safe inside Docker
  echo 'RemoteIPTrustedProxy 10.0.0.0/8'; \
  echo 'RemoteIPTrustedProxy 172.16.0.0/12'; \
  echo 'RemoteIPTrustedProxy 192.168.0.0/16'; \
  echo 'RemoteIPTrustedProxy 169.254.0.0/16'; \
  echo 'RemoteIPTrustedProxy 127.0.0.0/8'; \
  } > /etc/apache2/conf-available/remoteip.conf; \
  a2enconf remoteip; \
  # https://github.com/docker-library/wordpress/issues/383#issuecomment-507886512
  # (replace all instances of "%h" with "%a" in LogFormat)
  find /etc/apache2 -type f -name '*.conf' -exec sed -ri 's/([[:space:]]*LogFormat[[:space:]]+"[^"]*)%h([^"]*")/\1%a\2/g' '{}' +

COPY ./wp-content/ /var/www/html/wp-content/
COPY ./data/uploads.ini /usr/local/etc/php/conf.d/uploads.ini

VOLUME /var/www/html

EXPOSE 80

ENV WORDPRESS_VERSION 6.0.1

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
