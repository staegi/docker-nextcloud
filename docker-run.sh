#!/usr/bin/env bash
set -e
set -o pipefail

chown -R www-data:www-data /var/www/html

if sudo -u www-data php occ status|grep 'Nextcloud is not installed'; then
    echo 'Installing Nextcloud ...'
    cat > config/autoconfig.php <<EOF;
<?php
\$AUTOCONFIG = array_filter(array(
'directory'         => '/var/www/html/data',
'dbtype'            => '${NEXTCLOUD_DB_TYPE}',
'dbhost'            => '${NEXTCLOUD_DB_HOST}',
'dbport'            => '${NEXTCLOUD_DB_PORT}',
'dbname'            => '${NEXTCLOUD_DB_NAME}',
'dbuser'            => '${NEXTCLOUD_DB_USER}',
'dbpass'            => '${NEXTCLOUD_DB_PASSWORD}',
'dbtableprefix'     => '${NEXTCLOUD_DB_TABLE_PREFIX}',
'adminlogin'        => '${NEXTCLOUD_ADMIN_USER}',
'adminpass'         => '${NEXTCLOUD_ADMIN_PASSWORD}',
));
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

    if [ -n "$NEXTCLOUD_REDIS_HOST" ]; then
        echo "Added Redis settings"
        echo "\$CONFIG['redis'] = ['host'=>'$NEXTCLOUD_REDIS_HOST','port'=>$NEXTCLOUD_REDIS_PORT,'timeout'=>$NEXTCLOUD_REDIS_TIMEOUT,'password'=>'$NEXTCLOUD_REDIS_PASSWORD','dbindex'=>$NEXTCLOUD_REDIS_INDEX];" >> config/config.php
    fi

    if [ -n "$NEXTCLOUD_SMTP_FROM" ]; then
        echo "Added mail settings"
        from=$(echo ${NEXTCLOUD_SMTP_FROM} | cut -d "@" -f 1)
        domain=$(echo ${NEXTCLOUD_SMTP_FROM} | cut -d "@" -f 2)
        echo "\$CONFIG['mail_from_address'] = '$from';" >> config/config.php
        echo "\$CONFIG['mail_domain'] = '$domain';" >> config/config.php
        if [ -n "$NEXTCLOUD_SMTP_HOST" ]; then
            echo "\$CONFIG['mail_smtpmode'] = 'smtp';" >> config/config.php
            echo "\$CONFIG['mail_smtpport'] = '$NEXTCLOUD_SMTP_PORT';" >> config/config.php
            echo "\$CONFIG['mail_smtphost'] = '$NEXTCLOUD_SMTP_HOST';" >> config/config.php
            if [ -n "$NEXTCLOUD_SMTP_ENCRYPTION" ]; then
                echo "\$CONFIG['mail_smtpsecure'] = '$NEXTCLOUD_SMTP_ENCRYPTION';" >> config/config.php
            fi
            if [ -n "$NEXTCLOUD_SMTP_AUTH" ]; then
                echo "\$CONFIG['mail_smtpauth'] = 1;" >> config/config.php
                echo "\$CONFIG['mail_smtpauthtype'] = '$NEXTCLOUD_SMTP_AUTH_TYPE';" >> config/config.php
                echo "\$CONFIG['mail_smtpname'] = '$NEXTCLOUD_SMTP_AUTH_USER';" >> config/config.php
                echo "\$CONFIG['mail_smtppassword'] = '$NEXTCLOUD_SMTP_AUTH_PASSWORD';" >> config/config.php
            fi
        else
            echo "\$CONFIG['mail_smtpmode'] = 'php';" >> config/config.php
        fi
    fi
fi

sudo -u www-data php occ upgrade -n

apache2-foreground
