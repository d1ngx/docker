#!/bin/sh
set -eu

# return true if specified directory is empty
directory_empty() {
    [ -z "$(ls -A "$1/")" ]
}

# if [ ! -f "/var/www/html/config/data/install.lock" ] && [ ! -f "/var/www/html/config/config/setting_user.php" ] 
if  directory_empty "/var/www/html"; then
        if [ "$(id -u)" = 0 ]; then
            rsync_options="-rlDog --chown nginx:root"
        else
            rsync_options="-rlD"
        fi
        rsync $rsync_options --delete /usr/src/kodbox/ /var/www/html/
else
        echo "KODBOX has been configured!"
fi

# check ssl
if  directory_empty "/etc/nginx/ssl"; then
        echo "ssl not defined"
else 
        ln -s /etc/nginx/sites-available/private-ssl.conf /etc/nginx/sites-enabled/
fi

exec "$@"

