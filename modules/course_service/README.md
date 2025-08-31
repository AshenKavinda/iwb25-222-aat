# Course Service

This module handles all course-related operations for the school performance management system.

## Features

### Core Operations
- **Add Course**: Create new courses with validation
- **Update Course**: Modify existing course details
- **Soft Delete**: Mark courses as deleted without removing from database
- **Restore**: Restore soft-deleted courses
- **Get All**: Retrieve all active courses
- **Get By ID**: Retrieve specific course by ID

### Advanced Features
- **Get Available Years**: Get all unique years from courses
- **Search by Name**: Search courses by name pattern
- **Search by Year**: Search courses by specific year
- **Search by Name and Year**: Combined search functionality

### Security & Validation
- **Role-Based Access Control**: Only officers can perform course operations
- **User Validation**: Validates user exists and has officer role
- **Data Integrity**: Validates course ownership before operations

## Database Schema

The service works with the `course` table:

```sql
CREATE TABLE course (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    hall VARCHAR(255),
    year VARCHAR(10) NOT NULL,
    user_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL DEFAULT NULL
);
```

## API Endpoints

### Course Operations
- `POST /` - Add new course
- `GET /` - Get all courses
- `GET /{courseId}` - Get course by ID
- `PUT /{courseId}` - Update course
- `DELETE /{courseId}` - Soft delete course
- `POST /{courseId}/restore` - Restore deleted course

### Additional Endpoints
- `GET /deleted` - Get all deleted courses
- `GET /years` - Get all available years
- `GET /search/name/{name}` - Search by name
- `GET /search/year/{year}` - Search by year
- `GET /search/name/{name}/year/{year}` - Search by name and year

## Usage Examples

### Add Course
```json
POST /
{
    "name": "Grade 10 Science",
    "hall": "Science Lab A",
    "year": "2024",
    "user_id": 1
}
```

### Update Course
```json
PUT /123
{
    "name": "Grade 10 Advanced Science",
    "hall": "Science Lab B"
}
```

### Search Courses
```
GET /search/name/Science
GET /search/year/2024
GET /search/name/Science/year/2024
```

## Error Handling

The service returns appropriate error responses for:
- Invalid user or role validation failures
- Course not found scenarios
- Database operation failures
- Validation errors

All errors include descriptive messages and error codes for proper client handling.
