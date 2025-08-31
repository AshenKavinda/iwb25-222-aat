# Subject Service

This module handles all subject-related operations in the school performance panel system.

## Features

- **Add Subjects**: Create new subjects with name and weight validation
- **Update Subjects**: Modify existing subject details
- **Soft Delete & Restore**: Safely delete and restore subjects without losing data
- **Get All Subjects**: Retrieve all active subjects
- **Get Subject by ID**: Fetch specific subject details
- **Search by Name**: Find subjects by name pattern matching
- **Role-based Access Control**: Only officers can perform subject operations

## Subject Properties

- **subject_id**: Unique identifier (auto-generated)
- **name**: Subject name (required)
- **weight**: Subject weight between 1.0 and 10.0 (required)
- **user_id**: ID of the officer who created the subject (required)
- **created_at**: Timestamp when subject was created
- **updated_at**: Timestamp when subject was last updated
- **deleted_at**: Timestamp when subject was soft deleted (null for active subjects)

## Weight Validation

The subject weight must be between 1.0 and 10.0 (inclusive):
- Minimum weight: 1.0
- Maximum weight: 10.0
- Supports decimal values (e.g., 5.5, 7.25)

## Role-based Access Control

- Only users with **officer** role can perform subject operations
- User validation is performed for every operation
- User must exist and not be deleted
- User must have the correct role

## API Endpoints

The subject service runs on port **8084** and provides the following REST endpoints:

### Base URL: `http://localhost:8084/subjects`

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/` | Add new subject |
| GET | `/` | Get all active subjects |
| GET | `/{id}` | Get subject by ID |
| PUT | `/{id}` | Update subject |
| DELETE | `/{id}` | Soft delete subject |
| POST | `/{id}/restore` | Restore deleted subject |
| GET | `/deleted` | Get all deleted subjects |
| GET | `/search/{name}` | Search subjects by name |

## Request/Response Examples

### Add Subject
```json
// Request
POST /subjects
{
    "name": "Mathematics",
    "weight": 8.5,
    "user_id": 1
}

// Response
{
    "message": "Subject added successfully",
    "data": {
        "subject_id": 1,
        "name": "Mathematics",
        "weight": 8.5,
        "user_id": 1,
        "created_at": "2025-08-25T10:30:00",
        "updated_at": "2025-08-25T10:30:00",
        "deleted_at": null
    }
}
```

### Update Subject
```json
// Request
PUT /subjects/1
{
    "name": "Advanced Mathematics",
    "weight": 9.0
}

// Response
{
    "message": "Subject updated successfully",
    "data": {
        "subject_id": 1,
        "name": "Advanced Mathematics",
        "weight": 9.0,
        "user_id": 1,
        "created_at": "2025-08-25T10:30:00",
        "updated_at": "2025-08-25T10:35:00",
        "deleted_at": null
    }
}
```

### Error Response
```json
{
    "message": "Weight must be between 1 and 10",
    "error": "ADD_SUBJECT_ERROR"
}
```

## Database Schema

The subject service uses the following database table:

```sql
CREATE TABLE subject (
    subject_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    weight DECIMAL(5,2),
    user_id INT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES user(user_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL DEFAULT NULL
);
```

## Functions

### Service Functions
- `addSubject(AddSubjectRequest)`: Add new subject with validation
- `updateSubject(int, UpdateSubjectRequest)`: Update existing subject
- `softDeleteSubject(int)`: Soft delete subject
- `restoreSubject(int)`: Restore deleted subject
- `getAllSubjects()`: Get all active subjects
- `getSubjectById(int)`: Get subject by ID
- `getDeletedSubjects()`: Get all deleted subjects
- `searchSubjectsByName(string)`: Search subjects by name

### Database Functions
- `validateUserIsOfficer(int)`: Validate user exists and is officer
- `validateSubjectBelongsToOfficer(int)`: Validate subject belongs to officer
- `validateDeletedSubjectBelongsToOfficer(int)`: Validate deleted subject belongs to officer
- `validateWeight(decimal)`: Validate weight is within range (1-10)

## Testing

### Unit Tests
Run the unit tests using:
```bash
bal test modules/subject_service
```

### API Tests
Use the PowerShell script to test API endpoints:
```powershell
.\test_subject_service.ps1
```

The test script will:
1. Add a new subject
2. Get all subjects
3. Get subject by ID
4. Update subject
5. Search subjects by name
6. Soft delete subject
7. Get deleted subjects
8. Restore subject
9. Verify restoration
10. Test invalid weight validation
11. Cleanup test data

## Error Handling

The service handles various error scenarios:

- **USER_VALIDATION_ERROR**: User validation failed
- **INVALID_USER_OR_ROLE**: User doesn't exist or isn't an officer
- **ADD_SUBJECT_ERROR**: Failed to add subject (e.g., invalid weight)
- **UPDATE_SUBJECT_ERROR**: Failed to update subject
- **SUBJECT_VALIDATION_ERROR**: Subject validation failed
- **INVALID_SUBJECT_OR_USER**: Subject doesn't exist or doesn't belong to officer
- **DELETE_ERROR**: Failed to delete subject
- **RESTORE_ERROR**: Failed to restore subject
- **FETCH_ERROR**: Failed to retrieve subjects
- **SUBJECT_NOT_FOUND**: Subject not found
- **SEARCH_ERROR**: Failed to search subjects

## Dependencies

- `ballerina/http`: HTTP service capabilities
- `ballerina/sql`: SQL operations
- `ballerinax/mysql`: MySQL database connectivity
- `ballerina/log`: Logging functionality
- `ballerina/test`: Testing framework
