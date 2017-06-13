# docker-nextcloud

## This is a Docker container for Nextcloud

### Environment variables with default values

* NEXTCLOUD_DB_TYPE=mysql
* NEXTCLOUD_DB_HOST=database
* NEXTCLOUD_DB_POST=3306
* NEXTCLOUD_DB_NAME=nextcloud
* NEXTCLOUD_DB_USER=nextcloud
* NEXTCLOUD_DB_PASSWORD
* NEXTCLOUD_DB_TABLE_PREFIX=oc_
* NEXTCLOUD_ADMIN_USER=admin
* NEXTCLOUD_ADMIN_PASSWORD
* NEXTCLOUD_TRUSTED_DOMAINS
* NEXTCLOUD_REDIS_HOST
* NEXTCLOUD_REDIS_PORT=6379
* NEXTCLOUD_REDIS_INDEX=0
* NEXTCLOUD_REDIS_TIMEOUT=0.0
* NEXTCLOUD_REDIS_PASSWORD=''

### Volumes

    /var/www/html/custom_apps
    /var/www/html/data
    /var/www/html/themes
 
### Run with Docker Composer

    docker-compose up -d
    
### Run with Docker directly

    docker run -d -p 8080:80 --link database:database -e NEXTCLOUD_DB_PASSWORD=secret -e NEXTCLOUD_ADMIN_PASSWORD=secret nextcloud
    

    
