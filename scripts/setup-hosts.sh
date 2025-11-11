#!/bin/bash

# Script to setup hosts entries for local development

echo "Setting up hosts entries for Flask app..."

HOSTS_ENTRIES="
127.0.0.1 flask-app.local
127.0.0.1 api.flask-app.local
127.0.0.1 admin.flask-app.local"

# Check if entries already exist
if grep -q "flask-app.local" /etc/hosts; then
    echo "Hosts entries already exist. Updating..."
    sudo sed -i.bak '/flask-app.local/d' /etc/hosts
fi

# Add new entries
echo "$HOSTS_ENTRIES" | sudo tee -a /etc/hosts > /dev/null

echo "Hosts entries added:"
echo "127.0.0.1 flask-app.local"
echo "127.0.0.1 api.flask-app.local"
echo "127.0.0.1 admin.flask-app.local"
echo ""
echo "You can now access your application at:"
echo "  http://flask-app.local"
echo "  http://api.flask-app.local"
echo "  http://admin.flask-app.local"