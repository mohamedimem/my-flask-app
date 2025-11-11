#!/bin/bash

echo "Testing Ingress configuration..."

echo ""
echo "1. Testing main application via Ingress:"
curl -H "Host: flask-app.local" http://localhost
echo ""

echo "2. Testing health endpoint via Ingress:"
curl -H "Host: flask-app.local" http://localhost/health
echo ""

echo "3. Testing config endpoint via Ingress:"
curl -H "Host: flask-app.local" http://localhost/config
echo ""

echo "4. Testing API endpoint via Ingress:"
curl -H "Host: api.flask-app.local" http://localhost
echo ""

echo "5. Testing admin endpoint via Ingress:"
curl -H "Host: admin.flask-app.local" http://localhost
echo ""

echo "=== Ingress Test Complete ==="