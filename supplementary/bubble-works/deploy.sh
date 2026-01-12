#!/bin/bash

# Configuration
REPO_URL="https://github.com/your-username/bubble-works.git" # Replace with actual repo URL
APP_DIR="bubble-works"

# Arguments
SERVER_IP=$1
PORT=${2:-3000}

deploy_locally() {
    echo "Deploying locally on port $PORT..."
    export PORT=$PORT
    npm install
    npm run start
}

deploy_remotely() {
    echo "Deploying remotely to $SERVER_IP on port $PORT..."
    
    ssh "$SERVER_IP" << EOF
        # Check if directory exists
        if [ ! -d "$APP_DIR" ]; then
            git clone "$REPO_URL" "$APP_DIR"
        fi
        
        cd "$APP_DIR"
        git pull origin main
        
        # Install and run
        export PORT=$PORT
        npm install
        # Note: Using nohup or a process manager like pm2 would be better for remote
        npm run start & 
        echo "Application started in background on port $PORT"
EOF
}

if [ -z "$SERVER_IP" ]; then
    deploy_locally
else
    deploy_remotely
fi
