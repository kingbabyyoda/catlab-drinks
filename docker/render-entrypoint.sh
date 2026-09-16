#!/bin/bash
set -e

cd /var/www/html

# Render runs containers with no-new-privileges, so do not use sudo.
# Laravel/Apache needs these directories writable by www-data.
mkdir -p storage/logs storage/framework/cache storage/framework/sessions storage/framework/views bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
chmod -R ug+rwX storage bootstrap/cache

# Run the application's existing first-run setup/migrations as root.
bash docker/startup.sh

# startup.sh may recreate/change Laravel runtime files, so enforce the
# permissions once more before Apache starts.
chown -R www-data:www-data storage bootstrap/cache
chmod -R ug+rwX storage bootstrap/cache

exec apache2-foreground
