#!/bin/bash -x

### upgrade packages
apt-get update
apt-get -y upgrade

### install other needed packages
apt-get -y install aptitude vim nano psmisc cron curl
apt-get -y install openssh-server mysql-server ssmtp \
        phpmyadmin memcached php-memcached php-mysql \
        php-gd php-db php-dev php-pear php-curl php-apcu \
        make ssl-cert gawk unzip wget curl diffutils git ruby
apt-get -y install screen logwatch

### install nodejs and less
apt-get -y install npm
ln -s /usr/bin/nodejs /usr/bin/node
npm install -g less

### install hub: http://hub.github.com/
curl http://hub.github.com/standalone -sLo /bin/hub
chmod +x /bin/hub

### install twitter cli client
### see also: http://xmodulo.com/2013/12/access-twitter-command-line-linux.html
apt-get -y install ruby-dev
gem install t
useradd --system --create-home twitter

### phpmyadmin will install apache2 and start it
### so we should stop it
/etc/init.d/apache2 stop

### install nginx and php-fpm
apt-get -y install nginx nginx-common nginx-full php-fpm
/etc/init.d/nginx stop
update-rc.d nginx disable
/etc/init.d/php7.0-fpm stop
update-rc.d php7.0-fpm disable

# install uploadprogress bar (requested by Drupal 7)
#pecl install uploadprogress
git clone https://git.php.net/repository/pecl/php/uploadprogress.git
cd uploadprogress/
phpize
./configure
make
make install
cd ..
echo "extension = uploadprogress.so" > /etc/php/7.0/mods-available/uploadprogress.ini
ln -s /etc/php/7.0/mods-available/uploadprogress.ini /etc/php/7.0/apache2/conf.d/
ln -s /etc/php/7.0/mods-available/uploadprogress.ini /etc/php/7.0/fpm/conf.d/

# install drush
wget http://files.drush.org/drush.phar
chmod +x drush.phar
mv drush.phar /usr/local/bin/drush
drush --yes init

# install certbot (for getting ssl certs with letsencrypt)
wget https://dl.eff.org/certbot-auto
chmod +x certbot-auto
mv certbot-auto /usr/local/bin/certboot
