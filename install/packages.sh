#!/bin/bash -x

### upgrade packages
apt-get update
apt-get -y upgrade

### install other needed packages
apt-get -y install aptitude vim nano screen psmisc cron \
        rsyslog logrotate ssmtp logwatch
apt-get -y install openssh-server apache2 mysql-server phpmyadmin \
        php-mysql php-gd php-db php-dev php-pear php-curl php-apcu \
        make ssl-cert gawk unzip wget curl diffutils git ruby

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

# install drush
wget http://files.drush.org/drush.phar
chmod +x drush.phar
mv drush.phar /usr/local/bin/drush
drush --yes init

# install certbot (for getting ssl certs with letsencrypt)
wget https://dl.eff.org/certbot-auto
chmod +x certbot-auto
mv certbot-auto /usr/local/bin/certboot
