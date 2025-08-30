# Student Subject Enrollment Service

This service manages the enrollment of students in subjects for specific courses in the school performance panel system.

## Features

### 1. Add Common Subjects to All Students in Course
- **Endpoint**: `POST /api/student-subject-enrollment/common`
- **Description**: Assigns subjects to all students enrolled in a specific course
- **Access**: Officer only
- **Request Body**:
```json
{
  "course_id": 1,
  "subject_ids": [1, 2, 3],
  "user_id": 5
}
```

### 2. Add Subjects to Specific Student
- **Endpoint**: `POST /api/student-subject-enrollment/student`
- **Description**: Assigns subjects to a specific student for a specific course
- **Access**: Officer only
- **Request Body**:
```json
{
  "student_id": 10,
  "course_id": 1,
  "subject_ids": [1, 2, 3],
  "user_id": 5
}
```

### 3. Update Student Subject Enrollment
- **Endpoint**: `PUT /api/student-subject-enrollment/{record_id}`
- **Description**: Updates an existing student subject enrollment record
- **Access**: Officer only
- **Request Body**:
```json
{
  "student_id": 10,
  "subject_id": 2,
  "course_id": 1
}
```

### 4. Delete Student Subject Enrollment
- **Endpoint**: `DELETE /api/student-subject-enrollment/{record_id}`
- **Description**: Hard deletes a student subject enrollment record
- **Access**: Officer only

### 5. Get Student Subject Enrollment by Record ID
- **Endpoint**: `GET /api/student-subject-enrollment/{record_id}`
- **Description**: Retrieves a specific enrollment record by its ID
- **Access**: Officer only

### 6. Get Student Subject Enrollments with Details
- **Endpoint**: `GET /api/student-subject-enrollment/student/{student_id}/course/{course_id}`
- **Description**: Gets all subject enrollments for a student in a specific course with detailed information
- **Access**: Officer only

## Key Features

- **Role-based Access Control**: All endpoints require officer role verification
- **Individual Insertions**: Uses individual insertions for bulk operations (no transactions)
- **Comprehensive Validations**:
  - User exists and is an officer
  - Student exists and is not soft deleted
  - Course exists and is not soft deleted
  - Subject exists and is not soft deleted
  - Student is enrolled in the specified course
  - Prevents duplicate enrollments
- **Hard Delete**: Uses hard delete instead of soft delete for enrollment records
- **Detailed Response**: Provides detailed subject information including name and weight

## Database Table

The service interacts with the `student_subject_course` table which has the following structure:
- `record_id` (Primary Key)
- `student_id` (Foreign Key to student table)
- `subject_id` (Foreign Key to subject table)
- `course_id` (Foreign Key to course table)
- `user_id` (Foreign Key to user table)
- `created_at`
- `updated_at`

## Error Handling

The service provides comprehensive error handling with specific error codes and messages for different scenarios:
- User validation errors
- Student validation errors
- Course validation errors
- Subject validation errors
- Enrollment validation errors
- Database operation errors

## Authorization

All endpoints require:
1. Authorization header with valid JWT token
2. User must have "officer" role
3. User ID must exist in the system

## Response Format

All responses follow a consistent format:
- Success responses include `message` and `data` fields
- Error responses include `message` and `error` fields
- HTTP status codes are used appropriately (200, 400, 401, 403, 500)
