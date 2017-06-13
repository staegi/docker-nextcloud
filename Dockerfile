FROM nextcloud
MAINTAINER Thomas Stägemann <thomas@staegemann.info>

RUN apt-get update && apt-get install -yq mysql-client vim sudo

ENV NEXTCLOUD_DB_TYPE mysql
ENV NEXTCLOUD_DB_NAME nextcloud
ENV NEXTCLOUD_DB_HOST database
ENV NEXTCLOUD_DB_PORT 3306
ENV NEXTCLOUD_DB_USER nextcloud
ENV NEXTCLOUD_DB_TABLE_PREFIX oc_
ENV NEXTCLOUD_ADMIN_USER admin
ENV NEXTCLOUD_REDIS_PORT 6379
ENV NEXTCLOUD_REDIS_INDEX 0
ENV NEXTCLOUD_REDIS_TIMEOUT 0.0
ENV NEXTCLOUD_REDIS_PASSWORD ''

VOLUME /var/www/html/custom_apps
VOLUME /var/www/html/data
VOLUME /var/www/html/themes

COPY docker-run.sh /usr/local/bin/run.sh
CMD ["run.sh"]
