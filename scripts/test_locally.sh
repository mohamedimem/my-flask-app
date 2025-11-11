#!/bin/bash

echo "=== Testing Flask App Locally ==="

# Set environment variables for local testing
export SECRET_KEY="do-or-do-not-there-is-no-try"
export DATABASE_URL="sqlite:///local.db"
export DEBUG="True"
export ENVIRONMENT="development"
export APP_NAME="Flask App - Local Development"
export LOG_LEVEL="DEBUG"

echo "Environment variables set:"
echo "SECRET_KEY: $SECRET_KEY"
echo "DATABASE_URL: $DATABASE_URL"
echo "DEBUG: $DEBUG"
echo "ENVIRONMENT: $ENVIRONMENT"
echo "APP_NAME: $APP_NAME"

echo ""
echo "Installing dependencies..."
pip install -r requirements.txt

echo ""
echo "Initializing database..."
python -c "
from app import app, db
with app.app_context():
    db.create_all()
    print('Database tables created!')
"

echo ""
echo "Starting Flask development server..."
echo "Access your app at: http://localhost:5000"
echo "Press Ctrl+C to stop the server"
echo ""

python crudapp.py