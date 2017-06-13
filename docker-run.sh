#!/usr/bin/env bash
set -e
set -o pipefail

chown -R www-data:www-data /var/www/html

if sudo -u www-data php occ status|grep 'Nextcloud is not installed'; then
    echo 'Installing Nextcloud ...'
    cat > config/autoconfig.php <<EOF;
<?php
\$AUTOCONFIG = array(
'directory'     => '/var/www/html/data',
'dbtype'        => '${NEXTCLOUD_DB_TYPE}',
'dbhost'        => '${NEXTCLOUD_DB_HOST}',
'dbport'        => '${NEXTCLOUD_DB_PORT}',
'dbname'        => '${NEXTCLOUD_DB_NAME}',
'dbuser'        => '${NEXTCLOUD_DB_USER}',
'dbpass'        => '${NEXTCLOUD_DB_PASSWORD}',
'dbtableprefix' => '${NEXTCLOUD_DB_TABLE_PREFIX}',
'adminlogin'    => '${NEXTCLOUD_ADMIN_USER}',
'adminpass'     => '${NEXTCLOUD_ADMIN_PASSWORD}',
);
EOF
    domains=$(echo ${NEXTCLOUD_TRUSTED_DOMAINS} | tr "," "\n")
    for domain in $domains
    do
        echo "Added trusted domain: $domain"
        echo "\$AUTOCONFIG['trusted_domains'][] = '$domain';" >> config/autoconfig.php
    done

    echo 'Finishing installation ...'
    php index.php &>/dev/null
    echo "\$CONFIG['installed'] = true;" >> config/config.php

    echo "Added Redis settings"
    if [ -n "$NEXTCLOUD_REDIS_HOST" ]; then
        echo "\$CONFIG['redis'] = ['host'=>'$NEXTCLOUD_REDIS_HOST','port'=>$NEXTCLOUD_REDIS_PORT,'timeout'=>$NEXTCLOUD_REDIS_TIMEOUT,'password'=>'$NEXTCLOUD_REDIS_PASSWORD','dbindex'=>$NEXTCLOUD_REDIS_INDEX];" >> config/config.php
    fi
fi

sudo -u www-data php occ upgrade -n

apache2-foreground
