FROM debian:bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        php8.2-fpm php8.2-mysql curl ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && curl -sSLo /usr/local/bin/wp \
        https://github.com/wp-cli/wp-cli/releases/download/v2.11.0/wp-cli-2.11.0.phar \
    && chmod +x /usr/local/bin/wp

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /var/www/html
EXPOSE 9000

ENTRYPOINT ["entrypoint.sh"]
CMD ["php-fpm8.2", "-F"]
