FROM php:7.4-cli
LABEL maintainer "contact@oliviermariejoseph.fr"

ENV EXT_APCU_VERSION=5.1.19

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git\
		imagemagick \
		less \
		mariadb-client msmtp \
		libc-client-dev \
		libfreetype6-dev \
		libjpeg-dev \
		libjpeg62-turbo-dev \
		libkrb5-dev \
		libmagickwand-dev \
		libmcrypt-dev \
		libicu-dev \
		libmemcached-dev \
		libxml2-dev \
		libpng-dev \
		libzip-dev \
		libssl-dev \
		unzip \
		vim \
		zip
RUN pecl install imagick; \
	pecl install memcached; \
	pecl install mcrypt-1.0.3; \
	pecl install redis; 

RUN docker-php-ext-configure gd --with-freetype --with-jpeg; \
	docker-php-ext-configure zip; \
	docker-php-ext-install gd; \
	PHP_OPENSSL=yes docker-php-ext-configure imap --with-kerberos --with-imap-ssl; \
	echo "extension=memcached.so" >> /usr/local/etc/php/conf.d/memcached.ini; \
	docker-php-ext-install pdo_mysql; \
	docker-php-ext-install opcache; \
	docker-php-ext-install soap; \
	docker-php-ext-install intl; \
	docker-php-ext-install zip; \
	docker-php-ext-install exif; \
	docker-php-ext-enable imagick mcrypt redis; \
	docker-php-ext-install bcmath; 

RUN docker-php-source extract; \
    mkdir -p /usr/src/php/ext/apcu; \
    curl -fsSL https://pecl.php.net/get/apcu-5.1.19.tgz | tar xvz -C /usr/src/php/ext/apcu --strip 1 ;\
    docker-php-ext-install apcu; \
    docker-php-source delete

RUN	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*;

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
    

RUN curl --silent --show-error https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer


RUN wget https://github.com/symfony/cli/releases/download/v4.20.3/symfony_linux_amd64.gz \
	gzip -d symfony_linux_amd64.gz \
	mv symfony_linux_amd64 /usr/local/bin/symfony &&  chmod a+x /usr/local/bin/symfony

WORKDIR /var/www/donpadre

EXPOSE 8000

CMD ["php symfony server:start --allow-http -d"]