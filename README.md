# School Performance Panel - Authentication Service

This is a Ballerina-based authentication service for the School Performance Panel application. It provides JWT-based authentication and authorization with support for multiple user roles.

## Features

- **User Authentication**: Email/password-based login for all user types
- **Self Registration**: Guest users can register themselves
- **JWT Authentication**: Secure token-based authentication
- **Refresh Tokens**: Long-lived tokens for seamless user experience
- **Role-based Authorization**: Support for multiple user roles
- **Database Integration**: MySQL database with soft delete functionality

## User Roles

- **Manager**: Full administrative access
- **Teacher**: Teacher-specific permissions
- **Officer**: Administrative officer permissions
- **Guest**: Limited guest access (can self-register)

## API Endpoints

### Authentication Endpoints

#### 1. Login
**POST** `/api/auth/login`

Login for all user types with email and password.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "userpassword123"
}
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "user_id": 1,
    "email": "user@example.com",
    "role": "guest",
    "created_at": "2025-08-23T10:00:00Z",
    "updated_at": "2025-08-23T10:00:00Z"
  },
  "message": "Login successful"
}
```

#### 2. Register
**POST** `/api/auth/register`

Self-registration for guest users only.

**Request Body:**
```json
{
  "email": "newuser@example.com",
  "password": "securepassword123",
  "name": "John Doe",
  "phone_number": "1234567890",
  "dob": "1990-01-01"
}
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "user_id": 2,
    "email": "newuser@example.com",
    "role": "guest",
    "created_at": "2025-08-23T10:05:00Z",
    "updated_at": "2025-08-23T10:05:00Z"
  },
  "message": "Registration successful"
}
```

#### 3. Refresh Token
**POST** `/api/auth/refresh`

Get a new access token using a refresh token.

**Request Body:**
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "message": "Token refreshed successfully"
}
```

#### 4. Get Current User
**GET** `/api/auth/me`

Get current user profile (requires authentication).

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "user_id": 1,
  "email": "user@example.com",
  "role": "guest",
  "created_at": "2025-08-23T10:00:00Z",
  "updated_at": "2025-08-23T10:00:00Z"
}
```

#### 5. Validate Token
**POST** `/api/auth/validate`

Validate an access token and get payload information.

**Headers:**
```
Authorization: Bearer <access_token>
```

**Response:**
```json
{
  "user_id": 1,
  "email": "user@example.com",
  "role": "guest",
  "exp": 1724428800,
  "iat": 1724425200,
  "jti": "unique-token-id"
}
```

### Health Check

#### Health Check
**GET** `/api/health`

Check if the service is running.

**Response:**
```json
{
  "status": "healthy",
  "service": "School Performance Panel Authentication API",
  "timestamp": "2025-08-23T00:00:00Z"
}
```

## Configuration

### Database Configuration
Update `Config.toml` with your MySQL database settings:

```toml
DB_HOST = "127.0.0.1"
DB_PORT = 3306
DB_USERNAME = "root"
DB_PASSWORD = "Ashen#321"
DB_NAME = "school_performance"
```

### JWT Configuration
```toml
JWT_SECRET = "your-secret-key-change-this-in-production"
ACCESS_TOKEN_EXPIRY_TIME = 3600  # 1 hour
REFRESH_TOKEN_EXPIRY_TIME = 604800  # 7 days
```

## Database Setup

1. Create a MySQL database named `school_performance`
2. Run the SQL schema from `schema.sql` to create the required tables
3. The database includes soft delete functionality with `deleted_at` columns

## Running the Service

1. **Install Ballerina**: Make sure you have Ballerina 2201.12.7 or later installed
2. **Setup Database**: Create the MySQL database and run the schema
3. **Configure**: Update `Config.toml` with your database credentials
4. **Run**: Execute the following command:

```bash
bal run
```

The service will start on port 8080.

## Security Features

- **Password Hashing**: Passwords are hashed using SHA-256
- **JWT Security**: Tokens are signed with HS256 algorithm
- **Input Validation**: Email format and password strength validation
- **Authorization**: Role-based access control
- **Soft Delete**: Database records are soft-deleted for audit trails

## Error Handling

The API returns appropriate HTTP status codes:

- **200**: Success
- **400**: Bad Request (validation errors)
- **401**: Unauthorized (invalid credentials/token)
- **409**: Conflict (email already exists)
- **500**: Internal Server Error

## Password Requirements

- Minimum 8 characters
- Must contain at least one letter
- Must contain at least one number

## Token Lifecycle

- **Access Token**: Valid for 1 hour (configurable)
- **Refresh Token**: Valid for 7 days (configurable)
- **Token Type**: Bearer tokens in Authorization header

## Example Usage with cURL

### Register a new user:
```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@example.com",
    "password": "securepassword123",
    "name": "John Doe",
    "phone_number": "1234567890"
  }'
```

### Login:
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "userpassword123"
  }'
```

### Get current user:
```bash
curl -X GET http://localhost:8080/api/auth/me \
  -H "Authorization: Bearer <your_access_token>"
```

## Development

### Testing
Run tests with:
```bash
bal test
```

### Building
Build the project:
```bash
bal build
```

## Project Structure

```
school_performance_panel/
├── main.bal                           # Main API endpoints
├── Ballerina.toml                     # Project configuration
├── Config.toml                        # Runtime configuration
├── schema.sql                         # Database schema
├── jwt_utils.txt                      # JWT utility reference
└── modules/
    └── authentication_service/
        ├── authentication_service.bal  # Main authentication logic
        ├── database.bal               # Database connection and operations
        ├── jwt_utils.bal             # JWT utilities
        └── tests/
            └── authentication_service_test.bal  # Unit tests
```

## Contributing

1. Follow Ballerina coding conventions
2. Add appropriate tests for new features
3. Update documentation for API changes
4. Ensure all tests pass before submitting

## License

This project is part of the School Performance Panel application for educational purposes.
