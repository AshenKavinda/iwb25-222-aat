# School Performance Analysis System

This is a comprehensive Ballerina-based system for analyzing and managing school performance data. The system provides a complete platform for educational institutions to track student progress, manage courses, analyze test results, and generate performance reports.

## System Overview

The School Performance Analysis System is a microservices-based application that enables educational institutions to:

- Track and analyze student academic performance
- Manage courses, subjects, and enrollment data
- Conduct and evaluate tests and assessments
- Generate comprehensive performance reports
- Provide role-based access for different stakeholders

## Core Features

- **Student Management**: Complete student lifecycle management with enrollment tracking
- **Course & Subject Management**: Comprehensive course and subject administration
- **Test & Assessment System**: Test creation, administration, and result analysis
- **Performance Analytics**: Advanced reporting and analytics for academic performance
- **User Authentication**: JWT-based authentication with role-based authorization
- **Database Integration**: MySQL database with soft delete functionality and data integrity

## User Roles

- **Manager**: Full administrative access to all system features and data
- **Teacher**: Access to course management, test creation, and student performance data
- **Officer**: Administrative access to student records and enrollment management
- **Guest**: Limited access for viewing public information and self-registration

## System Architecture

The system is built using a modular microservices architecture with the following services:

### Core Services

1. **Authentication Service** - User authentication and authorization
2. **User Service** - User profile and account management
3. **Student Service** - Student information and enrollment management
4. **Course Service** - Course and curriculum management
5. **Subject Service** - Subject definition and management
6. **Test Service** - Test creation and administration
7. **Report Service** - Performance analytics and reporting

### Enrollment Services

8. **Course Subject Enrollment Service** - Manages course-subject relationships
9. **Student Course Service** - Handles student course enrollments
10. **Student Subject Enrollment Service** - Manages student-subject enrollments
11. **Test Enrollment Service** - Manages student test registrations

## API Endpoints Overview

The system provides RESTful APIs for each service. All endpoints require appropriate authentication except for registration and health check endpoints.

### Key API Endpoints

#### Authentication & User Management
- **POST** `/api/auth/login` - User login
- **POST** `/api/auth/register` - Self-registration for guests
- **POST** `/api/auth/refresh` - Token refresh
- **GET** `/api/auth/me` - Get current user profile
- **POST** `/api/auth/validate` - Validate access token

#### Student Management
- **GET** `/api/students` - List all students
- **POST** `/api/students` - Create new student
- **GET** `/api/students/{id}` - Get student details
- **PUT** `/api/students/{id}` - Update student information
- **DELETE** `/api/students/{id}` - Delete student (soft delete)

#### Course & Subject Management
- **GET** `/api/courses` - List all courses
- **POST** `/api/courses` - Create new course
- **GET** `/api/subjects` - List all subjects
- **POST** `/api/subjects` - Create new subject

#### Test & Assessment
- **GET** `/api/tests` - List all tests
- **POST** `/api/tests` - Create new test
- **GET** `/api/tests/{id}/results` - Get test results
- **POST** `/api/tests/{id}/enroll` - Enroll students in test

#### Performance Reports
- **GET** `/api/reports/student/{id}` - Individual student performance report
- **GET** `/api/reports/course/{id}` - Course performance analytics
- **GET** `/api/reports/test/{id}` - Test performance analysis

#### Health Check
- **GET** `/api/health` - Service health status

### Sample API Usage

#### Student Registration and Course Enrollment
**1. Login to the System**
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "teacher@school.edu",
    "password": "teacherpass123"
  }'
```

**2. Create a New Student**
```bash
curl -X POST http://localhost:8080/api/students \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <access_token>" \
  -d '{
    "name": "John Smith",
    "email": "john.smith@student.edu",
    "student_id": "STU2024001",
    "grade": "10"
  }'
```

**3. Enroll Student in Course**
```bash
curl -X POST http://localhost:8080/api/student-courses \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <access_token>" \
  -d '{
    "student_id": 1,
    "course_id": 1,
    "enrollment_date": "2024-09-01"
  }'
```

**4. Generate Performance Report**
```bash
curl -X GET http://localhost:8080/api/reports/student/1 \
  -H "Authorization: Bearer <access_token>"
```

## Database Schema

The system uses a comprehensive MySQL database schema with the following key tables:

- **users** - System users (managers, teachers, officers, guests)
- **students** - Student information and profiles
- **courses** - Course definitions and details
- **subjects** - Subject information
- **tests** - Test and assessment definitions
- **enrollments** - Various enrollment relationships
- **test_results** - Student test scores and results
- **reports** - Generated performance reports

## Performance Analytics Features

### Student Performance Tracking
- Individual student progress over time
- Subject-wise performance analysis
- Test score trends and patterns
- Attendance and participation metrics

### Course Analytics
- Course completion rates
- Average performance by course
- Subject difficulty analysis
- Student engagement metrics

### Institutional Insights
- School-wide performance trends
- Teacher effectiveness metrics
- Resource utilization analysis
- Predictive performance modeling
```

## System Configuration

### Configuration File Setup
Create your `Config.toml` file with the following structure:

```toml
# Shared Database Configuration (used by all services)
[ashen.school_performance_panel.database_config]
DB_HOST = "127.0.0.1"
DB_PORT = 3306
DB_USERNAME = "root"
DB_PASSWORD = "your_password"
DB_NAME = "school_performance_2"

# JWT Configuration for authentication_service module  
[ashen.school_performance_panel.authentication_service]
JWT_SECRET = "school-performance-jwt-secret-key-change-this-in-production-make-it-longer-and-more-secure-for-better-security"
ACCESS_TOKEN_EXPIRY_TIME = 3600  # 1 hour in seconds
REFRESH_TOKEN_EXPIRY_TIME = 604800  # 7 days in seconds
```

### Configuration Details

**Database Configuration:**
- Update the database credentials with your MySQL settings
- Change `DB_PASSWORD` to your actual database password
- Modify `DB_NAME` if you want to use a different database name

**JWT Configuration:**
- Change `JWT_SECRET` to a secure, long random string for production
- `ACCESS_TOKEN_EXPIRY_TIME` is in seconds (default: 1 hour)
- `REFRESH_TOKEN_EXPIRY_TIME` is in seconds (default: 7 days)

## System Setup and Installation

### Prerequisites
- Ballerina Swan Lake 2201.12.7 or later
- MySQL 8.0 or later
- Java 11 or later (for Ballerina runtime)

### Installation Steps

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd school_performance_panel
   ```

2. **Setup Database**
   - Create a MySQL database named `school_performance`
   - Run the schema from `schema.sql` to create all required tables
   - Optionally, run `dummydata.sql` to populate with sample data

3. **Configure the System**
   - Update `Config.toml` with your database credentials
   - Set JWT secret and other security configurations

4. **Install Dependencies**
   ```bash
   bal pull
   ```

5. **Run the System**
   ```bash
   bal run
   ```

The system will start on port 8080 (configurable) and all services will be available.

## Security Features

- **Multi-layered Authentication**: JWT-based authentication with role-based authorization
- **Password Security**: Secure password hashing using SHA-256
- **Token Management**: Access and refresh token lifecycle management
- **Input Validation**: Comprehensive validation for all API inputs
- **SQL Injection Protection**: Parameterized queries and input sanitization
- **Data Privacy**: Soft delete functionality preserves audit trails
- **Role-based Access Control**: Granular permissions based on user roles

## System Testing

The project includes comprehensive test coverage for all services:

### Running Tests
```bash
# Run all tests
bal test

# Run tests for specific service
bal test modules/student_service

# Run tests with coverage
bal test --coverage
```

### Test Scripts
The project includes PowerShell test scripts for API testing:
- `test_api.ps1` - General API testing
- `test_student_service.ps1` - Student service testing
- `test_course_service.ps1` - Course service testing
- `test_report_service.ps1` - Report service testing
- And many more...

## Monitoring and Logging

### Health Monitoring
- Health check endpoints for all services
- Database connectivity monitoring
- Service dependency checking

### Logging
- Structured logging with configurable levels
- Request/response logging for debugging
- Error tracking and reporting
- Performance metrics collection

## Error Handling

The system implements comprehensive error handling with appropriate HTTP status codes:

- **200**: Success - Operation completed successfully
- **201**: Created - Resource created successfully
- **400**: Bad Request - Invalid input or validation errors
- **401**: Unauthorized - Invalid credentials or expired token
- **403**: Forbidden - Insufficient permissions for operation
- **404**: Not Found - Requested resource not found
- **409**: Conflict - Resource conflict (e.g., duplicate email)
- **422**: Unprocessable Entity - Invalid data format
- **500**: Internal Server Error - System error

## Data Validation

### Student Data Validation
- Email format validation
- Student ID uniqueness
- Grade level validation
- Date format validation

### Course and Subject Validation
- Course code uniqueness
- Subject prerequisite validation
- Enrollment capacity limits
- Schedule conflict detection

### Test and Assessment Validation
- Test date validation
- Score range validation
- Enrollment deadline enforcement
- Result submission validation

## Use Cases and Scenarios

### For Educational Administrators
- Monitor school-wide performance trends
- Generate comprehensive reports for stakeholders
- Track teacher effectiveness and resource utilization
- Analyze enrollment patterns and capacity planning

### For Teachers
- Create and manage tests and assessments
- Track individual student progress
- Generate class performance reports
- Manage course content and enrollment

### For Academic Officers
- Process student enrollment and transfers
- Maintain student records and transcripts
- Generate academic standing reports
- Coordinate course scheduling

### For Students and Parents (Guest Users)
- View academic progress and grades
- Access course information and schedules
- Review test results and feedback
- Track attendance and participation

## Development and Deployment

### Development Setup
```bash
# Install Ballerina
# Download from: https://ballerina.io/downloads/

# Clone and setup project
git clone <repository-url>
cd school_performance_panel
bal pull

# Setup development database
mysql -u root -p < schema.sql
mysql -u root -p < dummydata.sql

# Configure development environment
cp Config.toml.example Config.toml
# Edit Config.toml with your settings

# Run in development mode
bal run
```

### Testing in Development
```bash
# Run unit tests
bal test

# Run integration tests
.\test_api.ps1

# Run specific service tests
.\test_student_service.ps1
```

### Building for Production
```bash
# Build executable JAR
bal build

# The executable will be in target/bin/
java -jar target/bin/school_performance_panel.jar
```

## Project Structure

```
school_performance_panel/
├── main.bal                           # Main API orchestrator and routing
├── Ballerina.toml                     # Project configuration and dependencies
├── Dependencies.toml                  # Dependency lock file
├── Config.toml                        # Runtime configuration
├── schema.sql                         # Database schema definition
├── dummydata.sql                      # Sample data for testing
├── *.ps1                             # PowerShell test scripts
├── modules/
│   ├── authentication_service/        # User authentication and JWT handling
│   │   ├── authentication_service.bal
│   │   ├── database.bal
│   │   ├── jwt_utils.bal
│   │   ├── rest_api.bal
│   │   ├── types.bal
│   │   └── tests/
│   ├── user_service/                  # User profile management
│   ├── student_service/               # Student information management
│   ├── course_service/                # Course and curriculum management
│   ├── subject_service/               # Subject definition and management
│   ├── test_service/                  # Test creation and administration
│   ├── report_service/                # Performance analytics and reporting
│   ├── student_course_service/        # Student-course enrollment
│   ├── course_subject_enrollment_service/  # Course-subject relationships
│   ├── student_subject_enrollement_service/  # Student-subject enrollment
│   ├── test_enrollment_service/       # Test enrollment management
│   └── database_config/               # Shared database configuration
└── target/                           # Build artifacts and compiled binaries
    ├── bin/
    │   └── school_performance_panel.jar
    └── cache/
```

### Module Responsibilities

- **authentication_service**: Handles login, registration, JWT token management
- **user_service**: Manages user profiles and account information
- **student_service**: Comprehensive student data management
- **course_service**: Course creation, management, and administration
- **subject_service**: Subject definitions and curriculum management
- **test_service**: Test creation, scheduling, and administration
- **report_service**: Analytics, reporting, and performance insights
- **enrollment services**: Various enrollment and relationship management
- **database_config**: Shared database connection and configuration

## Contributing

### Development Guidelines
1. Follow Ballerina coding conventions and best practices
2. Write comprehensive unit tests for new features
3. Update API documentation for any endpoint changes
4. Ensure all existing tests pass before submitting changes
5. Use meaningful commit messages and branch names

### Code Style
- Use descriptive variable and function names
- Add appropriate comments for complex logic
- Follow consistent indentation and formatting
- Implement proper error handling and logging

### Testing Requirements
- Unit tests for all new functions and services
- Integration tests for API endpoints
- Test coverage should not decrease
- Include both positive and negative test cases

## License and Credits

This School Performance Analysis System is developed for educational purposes as part of a hackathon project. The system demonstrates modern microservices architecture using Ballerina and provides a comprehensive solution for educational data management and analytics.

**Technologies Used:**
- Ballerina Swan Lake - Primary development framework
- MySQL - Database management system
- JWT - Authentication and authorization
- REST APIs - Service communication
- PowerShell - Testing and automation scripts

**Development Team:** 
- Built for educational institutions to improve academic performance tracking and analysis

## Support and Documentation

For additional documentation, examples, and support:
- Check the individual module README files for service-specific documentation
- Review the test scripts for API usage examples
- Examine the schema.sql for database structure details
- Refer to the Config.toml for configuration options

## Future Enhancements

Planned features for future releases:
- Real-time performance dashboards
- Advanced analytics and machine learning insights
- Mobile application support
- Integration with external learning management systems
- Automated report generation and scheduling
- Enhanced security features and audit logging
