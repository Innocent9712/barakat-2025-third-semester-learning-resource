#!/bin/bash

# Exit on error
set -e

# Configuration
REPO_URL="https://github.com/Innocent9712/barakat-2025-third-semester-learning-resource.git"
APP_DIR="/var/www/bubble-works"
NODE_VERSION="20"

echo "Starting server setup..."

# 1. Update and install dependencies
echo "Installing Node.js, Nginx, and Git..."
sudo apt-get update -y
sudo apt-get install -y curl git gnupg nginx

# 2. Install Node.js
curl -fsSL https://deb.nodesource.com/setup_$NODE_VERSION.x | sudo -E bash -
sudo apt-get install -y nodejs

# 3. Setup application directory
echo "Setting up application directory..."
sudo mkdir -p $APP_DIR
sudo chown $USER:$USER $APP_DIR

# 4. Clone repository
if [ ! -d "$APP_DIR/.git" ]; then
    echo "Cloning repository..."
    git clone "$REPO_URL" "$APP_DIR/temp-repo"
    mv $APP_DIR/temp-repo/supplementary/bubble-works/* $APP_DIR/
    rm -rf $APP_DIR/temp-repo
else
    echo "Repository already exists, pulling updates..."
    cd $APP_DIR
    git pull origin main
fi

# 5. Install NPM dependencies
echo "Installing dependencies..."
cd $APP_DIR
npm install

# 6. Configure systemd service
echo "Configuring systemd service..."
# Assuming bubble-works.service exists in the repo
sudo cp $APP_DIR/bubble-works.service /etc/systemd/system/bubble-works.service

# Update the service file with the correct user and path
sudo sed -i "s|User=bubbleuser|User=$USER|g" /etc/systemd/system/bubble-works.service
sudo sed -i "s|Group=bubbleuser|Group=$(id -gn)|g" /etc/systemd/system/bubble-works.service
sudo sed -i "s|WorkingDirectory=/var/www/bubble-works|WorkingDirectory=$APP_DIR|g" /etc/systemd/system/bubble-works.service

sudo systemctl daemon-reload
sudo systemctl enable bubble-works
sudo systemctl restart bubble-works

# 7. Configure Nginx
echo "Configuring Nginx..."
sudo cp $APP_DIR/scripts/nginx-config /etc/nginx/sites-available/bubble-works
sudo ln -sf /etc/nginx/sites-available/bubble-works /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

sudo nginx -t
sudo systemctl restart nginx

echo "Setup complete! Your application should be running."
echo "Access it via your server's IP address."
