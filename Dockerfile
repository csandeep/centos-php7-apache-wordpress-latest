FROM codecloud/docker-centos-apache-php7
COPY docker-php-ext-* /usr/local/bin/
COPY docker-php-source /usr/local/bin/docker-php-source

ENV PATH="/usr/local/bin:${PATH}"

# install the PHP extensions we need
RUN set -ex; \
	\
	yum install -y \
		libjpeg-turbo.x86_64 \
        libjpeg-turbo-utils.x86_64 \
		libpng-devel.x86_64 \
        php70-php-pecl-memcache.x86_64 \
	; \
	yum clean all; \
	\
	echo "/usr/local/bin/docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr"; \
	echo "/usr/local/bin/docker-php-ext-install gd mysqli opcache"
# TODO consider removing the *-dev deps and only keeping the necessary lib* packages

# ensure www-data user exists
RUN set -x \
	&& groupadd -g 82 www-data \
	&& adduser -u 82 -g www-data www-data \
	&& sed -i "s/AllowOverride None/AllowOverride All/g" /etc/httpd/conf/httpd.conf

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /etc/php.d/opcache-recommended.ini

#RUN a2enmod rewrite expires

VOLUME /var/www/html

ENV WORDPRESS_VERSION 4.8
ENV WORDPRESS_SHA1 3738189a1f37a03fb9cb087160b457d7a641ccb4

RUN set -ex; \
	curl -o wordpress.tar.gz -fSL "https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz"; \
	echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c -; \
# upstream tarballs include ./wordpress/ so this gives us /usr/src/wordpress
	tar -xzf wordpress.tar.gz -C /usr/src/; \
	rm wordpress.tar.gz; \
	chown -R www-data:www-data /usr/src/wordpress

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN set -ex; \
	chmod +x /usr/local/bin/docker-entrypoint.sh;


ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]