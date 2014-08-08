#!/bin/bash -x

### set the right version to the make file
makefile="$code_dir/labdoo/build-labdoo.make"
sed -i $makefile -e '/^; version to be used/,$ d'
cat <<EOF >> $makefile
; version to be used
projects[labdoo][download][branch] = '$lbd_git_branch'
EOF

### retrieve all the projects/modules and build the application directory
rm -rf $drupal_dir
drush make --prepare-install --force-complete \
           --contrib-destination=profiles/labdoo \
           $makefile $drupal_dir

### fix some things on the application directory
cd $drupal_dir/profiles/labdoo/
cp -a libraries/bootstrap themes/contrib/bootstrap/

### Replace the profile labdoo with a version
### that is a git clone, so that any updates
### can be retrieved easily (without having to
### reinstall the whole application).
cd $drupal_dir/profiles/
mv labdoo labdoo-bak
cp -a $code_dir/labdoo .
### copy contrib libraries and modules
cp -a labdoo-bak/libraries/ labdoo/
cp -a labdoo-bak/modules/contrib/ labdoo/modules/
cp -a labdoo-bak/themes/contrib/ labdoo/themes/
### cleanup
rm -rf labdoo-bak/

### create the downloads dir
mkdir -p /var/www/downloads/
chown www-data /var/www/downloads/

### start mysqld manually, if it is not running
if test -z "$(ps ax | grep [m]ysqld)"
then
    nohup mysqld --user mysql >/dev/null 2>/dev/null &
    sleep 5  # give time mysqld to start
fi

### settings for the database and the drupal site
db_name=lbd
db_user=lbd
db_pass=lbd
site_name="Labdoo"
site_mail="admin@example.org"
account_name=admin
account_pass=admin
account_mail="admin@example.org"

### create the database and user
mysql='mysql --defaults-file=/etc/mysql/debian.cnf'
$mysql -e "
    DROP DATABASE IF EXISTS $db_name;
    CREATE DATABASE $db_name;
    GRANT ALL ON $db_name.* TO $db_user@localhost IDENTIFIED BY '$db_pass';
"

### start site installation
sed -e '/memory_limit/ c memory_limit = -1' -i /etc/php5/cli/php.ini
cd $drupal_dir
drush site-install --verbose --yes labdoo \
      --db-url="mysql://$db_user:$db_pass@localhost/$db_name" \
      --site-name="$site_name" --site-mail="$site_mail" \
      --account-name="$account_name" --account-pass="$account_pass" --account-mail="$account_mail"

### set propper directory permissions
mkdir -p sites/default/files/
chown -R www-data: sites/default/files/
mkdir -p cache/
chown -R www-data: cache/
