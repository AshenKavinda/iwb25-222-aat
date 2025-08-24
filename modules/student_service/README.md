# Student Service

This module manages all student-related operations in the school performance panel system.

## Features

- **Add Student** - Create a new student record
- **Update Student** - Modify existing student information
- **Soft Delete & Restore** - Mark students as deleted and restore them
- **Get All Students** - Retrieve all active students
- **Get Student by ID** - Retrieve a specific student
- **Search by Full Name** - Find students by their full name

## Access Control

All APIs in this service are **only accessible by officers** (`officer` role).

## Database Schema

The service uses the `student` table with the following structure:

```sql
CREATE TABLE student (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    parent_nic VARCHAR(20) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    dob DATE NOT NULL,
    user_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL DEFAULT NULL
);
```

## API Endpoints

### Base URL: `http://localhost:8080/api/student`

### 1. Add Student
- **Method**: `POST`
- **Endpoint**: `/`
- **Body**:
```json
{
    "parent_nic": "123456789V",
    "full_name": "John Doe", 
    "dob": "2005-01-15",
    "user_id": 1
}
```

### 2. Update Student
- **Method**: `PUT`
- **Endpoint**: `/{student_id}`
- **Body**:
```json
{
    "parent_nic": "987654321V",
    "full_name": "John Updated Doe",
    "dob": "2005-02-20"
}
```

### 3. Get All Students
- **Method**: `GET`
- **Endpoint**: `/`

### 4. Get Student by ID
- **Method**: `GET`
- **Endpoint**: `/{student_id}`

### 5. Search Students by Name
- **Method**: `GET`
- **Endpoint**: `/search?name={search_term}`

### 6. Soft Delete Student
- **Method**: `DELETE`
- **Endpoint**: `/{student_id}`

### 7. Restore Student
- **Method**: `POST`
- **Endpoint**: `/{student_id}/restore`

### 8. Get Deleted Students
- **Method**: `GET`
- **Endpoint**: `/deleted`

## Authorization

Each request must include a valid JWT token in the Authorization header:
```
Authorization: Bearer <your_jwt_token>
```

The token must be for a user with the `officer` role.

## Response Format

All responses follow this structure:

**Success Response:**
```json
{
    "message": "Operation successful",
    "data": { /* student data */ }
}
```

**Error Response:**
```json
{
    "message": "Error description",
    "error": "ERROR_CODE"
}
```

## Testing

Run the test script to verify all endpoints:
```powershell
.\test_student_service.ps1
```

## Dependencies

- `ballerina/sql`
- `ballerinax/mysql`
- `ballerina/http`
- `ballerina/log`
