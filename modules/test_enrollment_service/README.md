# Test Enrollment Service

This service manages the enrollment of students to tests for specific courses and subjects. It creates the mappings between students, courses, subjects, and tests in the database.

## Features

### Add Test Enrollments
- **Endpoint**: `POST /api/test-enrollment`
- **Description**: Takes a course ID and array of test IDs, then automatically enrolls all eligible students
- **Process**:
  1. Validates user is an officer
  2. Validates course exists
  3. Gets subject information for all provided tests
  4. Finds all students enrolled in those subjects for the given course
  5. Creates individual enrollment records for each student-test combination
- **Request Body**:
  ```json
  {
    "course_id": 1,
    "test_ids": [1, 2, 3],
    "user_id": 1
  }
  ```

### Delete Test Enrollments
- **Endpoint**: `DELETE /api/test-enrollment`
- **Description**: Removes all enrollment records for specific tests in a course (hard delete)
- **Process**:
  1. Validates user is an officer
  2. Validates course exists
  3. Deletes all records matching the course ID and test IDs
- **Request Body**:
  ```json
  {
    "course_id": 1,
    "test_ids": [1, 2, 3]
  }
  ```
- **Headers**: `user_id` (required)

## Role-Based Access Control
- Only officers can access these endpoints
- User validation is performed for all operations

## Validation
- User must be an officer
- Course must exist and not be deleted
- Test IDs array cannot be empty
- Tests must exist and not be deleted
- Students must be enrolled in the subjects related to the tests

## Database Operations
- Uses individual insertions (not bulk transactions as requested)
- Creates records in `student_test_course_subject` table
- Performs hard deletes (not soft deletes) for the delete operation

## Error Handling
- Comprehensive validation and error responses
- Detailed error messages for debugging
- Graceful handling of missing or invalid data
