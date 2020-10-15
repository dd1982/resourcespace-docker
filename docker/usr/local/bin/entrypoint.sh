#!/bin/bash

groupmod -o -g "$PGID" nginx
usermod -o -u "$PUID" nginx

# We add the nginx user to the root group, so it can execute binaries (exiftool, ffmpeg, etc).
# This is far from secure, but "it just works" and will do for now until a better fix is forumlated.
usermod -a -G root nginx
 
echo "********************"
echo " nginx user:"
echo "  PUID: ${PUID}"
echo "  PGID: ${PGID}"
id nginx

# Generate a new self signed SSL certificate when none is provided in the volume
if [ ! -f /etc/nginx/ssl/resourcespace.key  ] || [ ! -f /etc/nginx/ssl/resourcespace.crt ]
then
    echo "********************"
    openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/nginx/ssl/resourcespace.key -out /etc/nginx/ssl/resourcespace.crt -subj "/C=GB/ST=London/L=London/O=Self Signed/OU=IT Department/CN=resourcespace.org" &
fi

echo "********************"
echo " Running chown on app dir... this may take awhile..."
time chown -R nginx:nginx /var/www/app/. /var/tmp/nginx/ &
wait
echo " FINISHED. Starting main services..."
echo "********************"

exec /bin/s6-svscan /etc/services.d
