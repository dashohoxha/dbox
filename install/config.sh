#!/bin/bash

### get config settings from a file
if [ "$1" != '' ]
then
    settings=$1
    set -a
    source  $settings
    set +a
fi

lbd=/usr/local/src/labdoo/install

$lbd/config/domain.sh
$lbd/config/mysql_passwords.sh
$lbd/config/mysql_labdoo.sh
$lbd/config/gmailsmtp.sh
$lbd/config/drupalpass.sh

if [ "$development" = 'true' ]
then
    $lbd/../dev/make-dev-clone.sh
fi

### drush may create some css/js files with wrong permissions
chown www-data: -R /var/www/lbd*/sites/default/files/{css,js}

$lbd/config/mysqld.sh stop
