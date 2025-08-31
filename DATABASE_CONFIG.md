# Database Configuration Management

This project now uses centralized configuration management for database settings across all services.

## Configuration Structure

### Config.toml (Development Configuration)
The `Config.toml` file in the root directory contains your development configuration:

```toml
# Global Database Configuration (shared across all services)
[ashen.school_performance_panel]
DB_HOST = "127.0.0.1"
DB_PORT = 3306
DB_USERNAME = "root"
DB_PASSWORD = "Ashen#321"
DB_NAME = "school_performance"

# JWT Configuration for authentication_service module  
[ashen.school_performance_panel.authentication_service]
JWT_SECRET = "school-performance-jwt-secret-key-change-this-in-production"
ACCESS_TOKEN_EXPIRY_TIME = 3600  # 1 hour in seconds
REFRESH_TOKEN_EXPIRY_TIME = 604800  # 7 days in seconds
```

### Environment Variables (.env)
For production or different environments, you can create a `.env` file:

```bash
# Database Configuration
DB_HOST=your-production-host
DB_PORT=3306
DB_USERNAME=your-username
DB_PASSWORD=your-secure-password
DB_NAME=school_performance

# JWT Configuration
JWT_SECRET=your-production-jwt-secret
ACCESS_TOKEN_EXPIRY_TIME=3600
REFRESH_TOKEN_EXPIRY_TIME=604800
```

## How to Use

### Development Environment
1. Use the existing `Config.toml` file for development
2. All services will automatically use the global database configuration

### Production Environment
1. Copy `.env.example` to `.env`
2. Update the values in `.env` with your production settings
3. Environment variables will override Config.toml values

### Benefits of This Approach

1. **Centralized Configuration**: All database settings are in one place
2. **Environment Flexibility**: Easy to switch between development, staging, and production
3. **Security**: Sensitive data can be kept in environment variables
4. **Maintainability**: No need to update multiple files when database settings change
5. **Version Control Safety**: Config.toml and .env files are gitignored

## Security Notes

- Never commit `Config.toml` or `.env` files to version control
- Use strong passwords and secure JWT secrets in production
- Consider using environment variables for all sensitive configuration in production

## Migration Complete

All the following services now use the centralized configuration:
- authentication_service
- user_service
- course_service
- course_subject_enrollment_service
- student_course_service
- student_service
- student_subject_enrollement_service
- subject_service
- test_enrollment_service
- test_service
