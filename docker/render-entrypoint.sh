#!/bin/bash
set -e

cd /var/www/html

# Render blocks privilege escalation (sudo), while thecodingmachine/php's
# default entrypoint requires sudo. This entrypoint runs directly as root and
# therefore avoids that dependency.
bash docker/startup.sh

exec apache2-foreground
