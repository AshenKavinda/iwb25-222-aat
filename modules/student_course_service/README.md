# Student Course Service

This service manages the assignment of students to courses. It provides functionality for bulk student enrollment, managing enrollments, and retrieving enrollment information with proper role-based access control.

## Features

- **Bulk Student Enrollment**: Add multiple students to a course in a single request
- **Enrollment Management**: Update and delete student course records
- **Comprehensive Queries**: Get enrollments by student, course, or record ID
- **Detailed Views**: Retrieve enrollment information with student and course details
- **Role-Based Access Control**: All endpoints require officer role authentication
- **Proper Validations**: Input validation and data integrity checks

## Database Schema

The service works with the `student_course` table:

```sql
CREATE TABLE student_course (
    record_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    user_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES student(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES course(course_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

## API Endpoints

All endpoints require `Authorization: Bearer <access_token>` header and officer role.

### 1. Add Students to Course (Bulk)
- **POST** `/api/student-course`
- **Description**: Add multiple students to a course
- **Request Body**:
```json
{
    "course_id": 1,
    "student_ids": [1, 2, 3, 4],
    "user_id": 1
}
```

### 2. Update Student Course Record
- **PUT** `/api/student-course/{record_id}`
- **Description**: Update an existing student course record
- **Request Body**:
```json
{
    "student_id": 2,
    "course_id": 1
}
```

### 3. Delete Student Course Record
- **DELETE** `/api/student-course/{record_id}`
- **Description**: Hard delete a student course record
- **Response**: Success message with deleted record ID

### 4. Get Student Course by Record ID
- **GET** `/api/student-course/{record_id}`
- **Description**: Retrieve a specific student course record
- **Response**: Student course record details

### 5. Get All Courses for Student
- **GET** `/api/student-course/student/{student_id}`
- **Description**: Get all courses a student is enrolled in
- **Response**: Array of student course records

### 6. Get All Students in Course
- **GET** `/api/student-course/course/{course_id}`
- **Description**: Get all students enrolled in a specific course
- **Response**: Array of student course records

### 7. Get Student Courses with Details
- **GET** `/api/student-course/student/{student_id}/details`
- **Description**: Get courses for a student with full details (student name, course name, etc.)
- **Response**: Array of detailed student course records

### 8. Get Course Students with Details
- **GET** `/api/student-course/course/{course_id}/details`
- **Description**: Get students in a course with full details
- **Response**: Array of detailed student course records

## Data Types

### StudentCourse
```ballerina
public type StudentCourse record {
    int record_id?;
    int student_id;
    int course_id;
    int user_id;
    string created_at?;
    string updated_at?;
};
```

### StudentCourseWithDetails
```ballerina
public type StudentCourseWithDetails record {
    int record_id;
    int student_id;
    string student_name;
    int course_id;
    string course_name;
    string course_year;
    int user_id;
    string created_at;
    string updated_at;
};
```

## Request/Response Types

### Add Students to Course
- **Request**: `AddStudentsToCourseRequest`
- **Response**: `AddStudentsToCourseResponse`

### Update Student Course
- **Request**: `UpdateStudentCourseRequest`
- **Response**: `UpdateStudentCourseResponse`

### Delete Student Course
- **Response**: `DeleteStudentCourseResponse`

### Get Operations
- **Single Record**: `GetStudentCourseByIdResponse`
- **Multiple Records**: `GetStudentCoursesByStudentIdResponse` / `GetStudentCoursesByCourseIdResponse`
- **With Details**: `GetStudentCoursesWithDetailsResponse`

## Validation Rules

1. **Authorization**: All endpoints require valid JWT token with officer role
2. **Course ID**: Must be a positive integer and exist in the database
3. **Student IDs**: Must be positive integers and exist in the database
4. **User ID**: Must be a positive integer and be an officer
5. **Bulk Operations**: Student IDs array cannot be empty
6. **Duplicate Prevention**: Cannot enroll same student in same course twice
7. **Update Operations**: At least one field must be provided for updates

## Error Handling

The service returns appropriate HTTP status codes and error messages:

- **400 Bad Request**: Invalid input data or validation errors
- **401 Unauthorized**: Missing or invalid authorization token
- **403 Forbidden**: Insufficient privileges (non-officer users)
- **500 Internal Server Error**: Database or server errors

## Usage Examples

### Bulk Enroll Students
```bash
curl -X POST http://localhost:8080/api/student-course \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "course_id": 1,
    "student_ids": [1, 2, 3],
    "user_id": 1
  }'
```

### Get Student's Courses with Details
```bash
curl -X GET http://localhost:8080/api/student-course/student/1/details \
  -H "Authorization: Bearer <token>"
```

### Update Enrollment
```bash
curl -X PUT http://localhost:8080/api/student-course/1 \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "course_id": 2
  }'
```

## Testing

Run the PowerShell test script to test all endpoints:
```powershell
.\test_student_course_service.ps1
```

Or run the Ballerina unit tests:
```bash
bal test modules/student_course_service
```

## Security Features

- **JWT Authentication**: All endpoints require valid access tokens
- **Role-Based Access**: Only officers can access these endpoints
- **User Validation**: User IDs are validated against the database
- **Input Sanitization**: All inputs are validated before processing
- **Transaction Safety**: Bulk operations use database transactions
