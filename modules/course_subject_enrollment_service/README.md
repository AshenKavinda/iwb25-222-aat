# Course Subject Enrollment Service

This service manages the mapping between subjects, teachers, and courses using the `subject_course_teacher` table. It provides functionality to assign teachers to teach specific subjects in specific courses.

## Features

- **Add Course Subject Enrollment**: Create a new mapping between subject, course, and teacher
- **Update Course Subject Enrollment**: Update the subject_id field only for an existing enrollment
- **Delete Course Subject Enrollment**: Hard delete an enrollment record (no soft delete)
- **Get Enrollments by Course ID**: Retrieve all subject-teacher mappings for a specific course
- **Get Enrollments by Teacher ID**: Retrieve all course-subject assignments for a specific teacher with detailed information

## Role-Based Access Control

All endpoints require **Officer** role access only. The service validates:

- User must exist and have `officer` role
- User ID in requests must be verified as an officer

## Database Table

The service operates on the `subject_course_teacher` table with the following structure:

```sql
CREATE TABLE subject_course_teacher (
    record_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_id INT NOT NULL,
    course_id INT NOT NULL,
    teacher_id INT NOT NULL,
    user_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subject(subject_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES course(course_id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES user(user_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

## API Endpoints

### POST `/api/course-subject-enrollment`
Add a new course subject enrollment.

**Request Body:**
```json
{
    "subject_id": 1,
    "course_id": 1,
    "teacher_id": 2,
    "user_id": 3
}
```

**Response:**
```json
{
    "message": "Course subject enrollment added successfully",
    "data": {
        "record_id": 1,
        "subject_id": 1,
        "course_id": 1,
        "teacher_id": 2,
        "user_id": 3,
        "created_at": "2024-01-01T10:00:00Z",
        "updated_at": "2024-01-01T10:00:00Z"
    }
}
```

### PUT `/api/course-subject-enrollment/{record_id}`
Update the subject_id field of an existing enrollment.

**Request Body:**
```json
{
    "subject_id": 2
}
```

**Response:**
```json
{
    "message": "Course subject enrollment record updated successfully",
    "data": {
        "record_id": 1,
        "subject_id": 2,
        "course_id": 1,
        "teacher_id": 2,
        "user_id": 3,
        "created_at": "2024-01-01T10:00:00Z",
        "updated_at": "2024-01-01T10:05:00Z"
    }
}
```

### DELETE `/api/course-subject-enrollment/{record_id}`
Hard delete an enrollment record.

**Response:**
```json
{
    "message": "Course subject enrollment record deleted successfully",
    "record_id": 1
}
```

### GET `/api/course-subject-enrollment/course/{course_id}`
Get all subject-teacher enrollments for a specific course.

**Response:**
```json
{
    "message": "Course subject enrollments retrieved successfully",
    "data": [
        {
            "record_id": 1,
            "subject_id": 1,
            "course_id": 1,
            "teacher_id": 2,
            "user_id": 3,
            "created_at": "2024-01-01T10:00:00Z",
            "updated_at": "2024-01-01T10:00:00Z"
        }
    ]
}
```

### GET `/api/course-subject-enrollment/teacher/{teacher_id}`
Get all course-subject assignments for a specific teacher with detailed information.

**Response:**
```json
{
    "message": "Course subject enrollments with details retrieved successfully",
    "data": [
        {
            "record_id": 1,
            "subject_id": 1,
            "subject_name": "Mathematics",
            "subject_weight": 75.50,
            "course_id": 1,
            "course_name": "Grade 10 - A",
            "course_year": "2024",
            "course_hall": "Hall A",
            "teacher_id": 2,
            "teacher_name": "John Doe",
            "user_id": 3,
            "created_at": "2024-01-01T10:00:00Z",
            "updated_at": "2024-01-01T10:00:00Z"
        }
    ]
}
```

## Validations

### Add Course Subject Enrollment
- User must exist and have `officer` role
- Subject must exist and not be deleted
- Course must exist and not be deleted
- Teacher must exist and have `teacher` role
- Subject-Course-Teacher combination must be unique

### Update Course Subject Enrollment
- Subject must exist and not be deleted
- New Subject-Course-Teacher combination must be unique (excluding current record)

### Get by Course ID
- Course must exist and not be deleted

### Get by Teacher ID
- Teacher must exist and have `teacher` role

## Error Responses

All endpoints return error responses in the following format:

```json
{
    "message": "Error description",
    "error": "ERROR_CODE"
}
```

### Common Error Codes
- `MISSING_AUTHORIZATION`: Authorization header is required
- `INSUFFICIENT_PRIVILEGES`: Access denied. Officer role required
- `USER_VALIDATION_ERROR`: Failed to validate user
- `INVALID_USER_OR_ROLE`: User ID does not exist or user is not an officer
- `COURSE_VALIDATION_ERROR`: Failed to validate course
- `INVALID_COURSE`: Course not found or deleted
- `SUBJECT_VALIDATION_ERROR`: Failed to validate subject
- `INVALID_SUBJECT`: Subject not found or deleted
- `TEACHER_VALIDATION_ERROR`: Failed to validate teacher
- `INVALID_TEACHER`: Teacher ID does not exist or user is not a teacher
- `ADD_COURSE_SUBJECT_ENROLLMENT_ERROR`: Failed to add course subject enrollment
- `UPDATE_COURSE_SUBJECT_ENROLLMENT_ERROR`: Failed to update course subject enrollment record
- `DELETE_ERROR`: Failed to delete course subject enrollment record
- `FETCH_ERROR`: Failed to retrieve course subject enrollments
- `INVALID_RECORD_ID`: Invalid record ID
- `INVALID_SUBJECT_ID`: Invalid subject ID
- `INVALID_COURSE_ID`: Invalid course ID
- `INVALID_TEACHER_ID`: Invalid teacher ID
- `INVALID_USER_ID`: Invalid user ID

## Authorization

All endpoints require a valid JWT token with `officer` role in the Authorization header:

```
Authorization: Bearer <jwt_token>
```

## Testing

Use the provided test script `test_course_subject_enrollment_service.ps1` to test all endpoints. Make sure to:

1. Start the Ballerina service
2. Obtain a valid JWT token with officer role
3. Update the test script with actual IDs and token
4. Run the test script

## Dependencies

- MySQL database connection
- Authentication service for role validation
- Subject, Course, and User tables must exist with proper data
