#!/bin/sh

# Inject hostname into index.html
sed -i "s/{{HOSTNAME}}/$(hostname)/g" /usr/share/nginx/html/index.html

# Tail Nginx logs to stdout/stderr so 'kubectl logs' works
# This is necessary because mounting a volume to /var/log/nginx mask the default symlinks
touch /var/log/nginx/access.log /var/log/nginx/error.log
tail -f /var/log/nginx/access.log /var/log/nginx/error.log &

# Start Nginx
exec nginx -g "daemon off;"
