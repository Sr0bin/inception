#!/bin/sh
set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
. /run/secrets/credentials

if [ ! -f wp-load.php ]; then
    wp core download --allow-root
fi

if [ ! -f wp-config.php ]; then
    wp config create --allow-root \
        --dbname="$MYSQL_DATABASE" --dbuser="$MYSQL_USER" \
        --dbpass="$DB_PASSWORD" --dbhost=mariadb:3306
fi
wp config set DB_PASSWORD "$DB_PASSWORD" --allow-root

if ! wp core is-installed --allow-root 2>/dev/null; then
    wp core install --allow-root \
        --url="https://$DOMAIN_NAME" --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" --skip-email
fi

if ! wp user get "$WP_USER" --allow-root > /dev/null 2>&1; then
    wp user create --allow-root "$WP_USER" "$WP_USER_EMAIL" \
        --user_pass="$WP_USER_PASSWORD" --role=author
fi
wp user update "$WP_ADMIN_USER" --user_pass="$WP_ADMIN_PASSWORD" --allow-root
wp user update "$WP_USER" --user_pass="$WP_USER_PASSWORD" --allow-root

chown -R www-data:www-data /var/www/html

exec "$@"
