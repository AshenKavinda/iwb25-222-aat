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

## The api_collection directory contains the entire API collection (POSTMAN).

## Performance Analytics Features

The School Performance Analysis System provides comprehensive analytics capabilities to help educational institutions make data-driven decisions. The analytics features are primarily accessible to managers and administrators, with some public access for student-specific reports.

### Key Analytics Reports

- **Top Performing Students**: Identify high-achieving students by academic year and term (Term 1, Term 2, Term 3) with configurable result limits
- **Average Marks by Subject**: Analyze subject-wise performance across different courses and terms to identify strengths and areas for improvement
- **Teacher Performance Analytics**: Evaluate teacher effectiveness based on average student marks in their subjects
- **Student Progress Tracking**: Monitor individual student performance trends across multiple terms to track academic growth
- **Low Performing Subjects**: Identify subjects with average marks below a configurable threshold to target intervention strategies
- **Top Performing Courses**: Rank courses by average performance to recognize successful programs and teaching methodologies
- **Individual Student Reports**: Detailed marks breakdown for specific students across all subjects, tests, and terms

### Analytics Features

- **Role-based Access**: Most analytics require manager-level permissions, ensuring data security and privacy
- **Flexible Filtering**: Filter reports by academic year, term type, and performance thresholds
- **Real-time Data**: Reports are generated from live database queries for up-to-date insights
- **Comprehensive Coverage**: Analytics cover students, teachers, courses, subjects, and overall institutional performance
- **Performance Thresholds**: Configurable thresholds for identifying low-performing areas
- **Trend Analysis**: Track performance changes across terms and academic years

### Use Cases

- **Institutional Planning**: Use performance data to allocate resources and plan curriculum improvements
- **Teacher Development**: Identify areas where teachers may need additional support or training
- **Student Intervention**: Early identification of struggling students for targeted academic support
- **Curriculum Evaluation**: Assess the effectiveness of different courses and subjects
- **Stakeholder Reporting**: Generate comprehensive reports for school boards, parents, and regulatory bodies

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
- In database directory have database schema and dumy data set.
  - Initial officer
    - username : officer@example.com
    - password : password123
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
   - run `dummydata.sql` to populate with sample data

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

## Detailed Service Explanations

### Core Services

#### 1. Authentication Service (`authentication_service`)
The Authentication Service is the central security component that manages user authentication and authorization across the entire system.

**Key Features:**
- **User Login**: Validates user credentials and generates JWT access and refresh tokens
- **User Registration**: Allows guest users to register with the system (automatically assigned guest role)
- **Token Management**: Handles JWT token generation, validation, and refresh
- **Password Security**: Implements secure password hashing and validation
- **Role-based Authorization**: Provides helper functions to check user roles and permissions
- **Token Validation**: Validates access tokens and ensures user session integrity

**Security Features:**
- Email format validation
- Password strength requirements (minimum 8 characters, must contain letters and numbers)
- JWT token expiration management
- Secure token storage and transmission

#### 2. User Service (`user_service`)
The User Service manages all user-related operations including profile management and administrative user functions.

**Key Features:**
- **User Profile Management**: Create, read, update, and delete user profiles
- **Role Management**: Assign and update user roles (Manager, Teacher, Officer, Guest)
- **Soft Delete Functionality**: Safely remove users while preserving data integrity
- **User Search**: Search users by email with wildcard pattern matching
- **Bulk User Operations**: Handle multiple user operations efficiently
- **User Restoration**: Restore previously deleted users

**Administrative Functions:**
- Add users with profiles (email, password, role, personal information)
- Update user information (excluding email and password for security)
- Soft delete and restore users
- Retrieve all users or deleted users
- Search functionality for user management

#### 3. Student Service (`student_service`)
The Student Service handles comprehensive student lifecycle management with officer-based access control.

**Key Features:**
- **Student Registration**: Add new students with parent NIC validation
- **Student Profile Management**: Update student information (name, date of birth, parent details)
- **Officer-based Access Control**: All operations require officer user validation
- **Soft Delete & Restore**: Safely manage student records with audit trails
- **Student Search**: Search students by full name with pattern matching
- **Data Integrity**: Ensures students are properly linked to authorized officers

**Validation & Security:**
- User role validation (must be officer)
- Student ownership validation
- Parent NIC tracking for family relationships
- Comprehensive error handling and logging

#### 4. Course Service (`course_service`)
The Course Service manages academic course definitions and administration.

**Key Features:**
- **Course Creation**: Add new courses with hall assignments and academic years
- **Course Management**: Update course details and manage course lifecycle
- **Officer Authorization**: All course operations require officer-level permissions
- **Soft Delete Functionality**: Preserve course history while removing active courses
- **Course Search**: Find courses by name or filter by academic year
- **Hall Management**: Track course locations and facilities

**Administrative Features:**
- Course restoration from deleted state
- Bulk course retrieval and management
- Year-based filtering for academic planning
- Comprehensive validation of course data

#### 5. Subject Service (`subject_service`)
The Subject Service manages academic subject definitions and curriculum structure.

**Key Features:**
- **Subject Definition**: Create and manage academic subjects
- **Curriculum Management**: Organize subjects within the academic framework
- **Officer Control**: Subject management restricted to authorized officers
- **Subject Lifecycle**: Full CRUD operations with soft delete capabilities
- **Subject Search**: Find subjects by name or code
- **Academic Organization**: Support for subject categorization and prerequisites

#### 6. Test Service (`test_service`)
The Test Service handles test creation, administration, and management for academic assessments.

**Key Features:**
- **Test Creation**: Create tests with type validation (Term 1, Term 2, Term 3)
- **Test Scheduling**: Manage test dates, subjects, and academic years
- **Officer Authorization**: Test management restricted to authorized personnel
- **Test Types**: Support for different term-based assessments
- **Subject Association**: Link tests to specific academic subjects
- **Test Lifecycle Management**: Full CRUD operations with soft delete

**Advanced Features:**
- Test filtering by year, type, and subject
- Test search by name
- Available years retrieval for academic planning
- Comprehensive validation of test parameters

#### 7. Report Service (`report_service`)
The Report Service provides comprehensive analytics and performance reporting capabilities.

**Key Features:**
- **Top Performing Students**: Identify high-achieving students with configurable limits
- **Average Marks Analysis**: Analyze subject-wise performance across courses and terms
- **Teacher Performance Metrics**: Evaluate teacher effectiveness based on student outcomes
- **Student Progress Tracking**: Monitor academic growth across multiple terms
- **Low Performing Subjects**: Identify areas needing intervention
- **Top Performing Courses**: Recognize successful academic programs
- **Individual Student Reports**: Detailed performance breakdowns

**Analytics Capabilities:**
- Role-based access (primarily manager access)
- Flexible filtering by year, term, and performance thresholds
- Real-time data generation from live database queries
- Comprehensive coverage of academic performance metrics

### Enrollment Services

#### 8. Course Subject Enrollment Service (`course_subject_enrollment_service`)
Manages the relationships between courses and subjects in the curriculum.

**Key Features:**
- **Curriculum Mapping**: Associate subjects with specific courses
- **Enrollment Management**: Handle course-subject relationships
- **Academic Planning**: Support curriculum design and modification
- **Validation**: Ensure proper course and subject associations

#### 9. Student Course Service (`student_course_service`)
Handles student enrollment in courses and manages course participation.

**Key Features:**
- **Bulk Student Enrollment**: Add multiple students to courses simultaneously
- **Enrollment Tracking**: Monitor student course participation
- **Course Capacity Management**: Handle enrollment limits and availability
- **Student Progress**: Track student advancement through courses
- **Detailed Reporting**: Provide enrollment details with course and student information

**Advanced Features:**
- Student-course relationship management
- Enrollment validation and conflict detection
- Comprehensive enrollment reporting
- Support for course changes and transfers

#### 10. Student Subject Enrollment Service (`student_subject_enrollement_service`)
Manages student enrollment in individual subjects within their courses.

**Key Features:**
- **Subject-specific Enrollment**: Handle individual subject registrations
- **Prerequisite Management**: Ensure proper subject sequencing
- **Academic Planning**: Support individualized learning paths
- **Progress Tracking**: Monitor subject completion and performance

#### 11. Test Enrollment Service (`test_enrollment_service`)
Manages student registration for specific tests and assessments.

**Key Features:**
- **Test Registration**: Handle student sign-ups for assessments
- **Capacity Management**: Control test enrollment limits
- **Schedule Management**: Coordinate test dates and student availability
- **Assessment Tracking**: Monitor test participation and completion

### Infrastructure Services

#### 12. Database Configuration Service (`database_config`)
Provides centralized database configuration and connection management for all services.

**Key Features:**
- **Centralized Configuration**: Single source of truth for database settings
- **Connection Management**: Standardized database connection handling
- **Configuration Validation**: Ensure proper database connectivity
- **Security**: Secure credential management for database access

**Configuration Management:**
- Host, port, username, password, and database name configuration
- Environment-specific settings support
- Connection pooling and optimization
- Database migration and schema management support

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

## Future Enhancements

Planned features for future releases:
- Real-time performance dashboards
- Advanced analytics and machine learning insights
- Mobile application support
- Integration with external learning management systems
- Automated report generation and scheduling
- Enhanced security features and audit logging
