import os
basedir = os.path.abspath(os.path.dirname(__file__))

class Config(object):
    # Will be set from Kubernetes Secret
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'do-or-do-not-there-is-no-try'
    
    # Database configuration
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL') or \
        'sqlite:///' + os.path.join(basedir, 'app.db')
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    
    # Additional configuration from environment variables
    DEBUG = os.environ.get('DEBUG', 'false').lower() == 'true'
    ENVIRONMENT = os.environ.get('ENVIRONMENT', 'production')
    LOG_LEVEL = os.environ.get('LOG_LEVEL', 'INFO')
    
    # Application settings
    APP_NAME = os.environ.get('APP_NAME', 'Flask Application')
    MAX_CONTENT_LENGTH = int(os.environ.get('MAX_CONTENT_LENGTH', '16777216'))  # 16MB