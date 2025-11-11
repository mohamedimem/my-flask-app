from app import app, db
import os

if __name__ == '__main__':
    # Set environment variables for local testing
    os.environ['SECRET_KEY'] = 'do-or-do-not-there-is-no-try'
    os.environ['DATABASE_URL'] = 'sqlite:///local.db'
    os.environ['DEBUG'] = 'True'
    os.environ['ENVIRONMENT'] = 'development'
    os.environ['APP_NAME'] = 'Flask App - Local'
    
    # Create database tables
    with app.app_context():
        db.create_all()
        print("Database tables created!")
    
    print("Starting Flask development server...")
    print("Access your app at: http://localhost:5000")
    print("Health check: http://localhost:5000/health")
    print("Config: http://localhost:5000/config")
    
    app.run(host='0.0.0.0', port=5000, debug=True)