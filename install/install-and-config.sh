#!/bin/bash -x

export DEBIAN_FRONTEND=noninteractive

### read the settings if they are given
if test $1
then
    set -a
    source $1
    set +a
    container=true   # this is installation of a docker container
fi

### update /etc/apt/sources.list
cat << EOF > /etc/apt/sources.list
deb $apt_mirror $suite main restricted universe multiverse
deb $apt_mirror $suite-updates main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu $suite-security main restricted universe multiverse
EOF

### set a temporary hostname
sed -i /etc/hosts \
    -e "/^127.0.0.1/c 127.0.0.1 example.org localhost"
hostname example.org

### export drupal_dir
export drupal_dir=/var/www/lbd
export drush="drush --root=$drupal_dir"

### go to the directory of scripts
cd $code_dir/install/scripts/

### additional packages and software
./packages-and-software.sh

### make and install the drupal profile 'labdoo'
./drupal-make-and-install.sh

### additional configurations related to drupal
./drupal-config.sh

### system level configuration (services etc.)
./system-config.sh

### labdoo configuration
$code_dir/install/config.sh
