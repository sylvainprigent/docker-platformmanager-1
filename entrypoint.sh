#!/bin/bash
set -e

service atd start

cp /etc/platformmanager/conf.ini.sample /var/www/platformmanager/Config/conf.ini
sed -i "s/MYSQL_URL/${MYSQL_HOST}/g" /var/www/platformmanager/Config/conf.ini
sed -i "s/MYSQL_DBNAME/${MYSQL_DBNAME}/g" /var/www/platformmanager/Config/conf.ini
sed -i "s/MYSQL_USER/${MYSQL_USER}/g" /var/www/platformmanager/Config/conf.ini
sed -i "s/MYSQL_PASS/${MYSQL_PASS}/g" /var/www/platformmanager/Config/conf.ini

# make sure this is not accessible from the webapp (no risk of leak)
unset MYSQL_USER
unset MYSQL_PASS

if [ ! -e /var/www/platformmanager/data/core ]; then
    cp -r /opt/data/* /var/www/platformmanager/data/
fi

chown -R www-data:www-data /var/www/platformmanager/data

# Run the database update script in a few seconds
echo "sleep 10; curl http://localhost/caches > /var/log/startup_db_caches.log; curl http://localhost/update > /var/log/startup_db_update.log" | at now

exec apache2-foreground
