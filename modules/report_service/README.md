# Report Service

This module provides comprehensive reporting functionality for school performance analysis at the organizational high level.

## Features

The report service provides the following key reports:

### 1. Top Performing Students
- **Endpoint**: `GET /api/reports/topstudents?year={year}&term_type={term_type}&limitCount={limitCount}`
- **Description**: Get top performing students by total marks for a specific term and year
- **Parameters**:
  - `year` (required): Academic year (e.g., "2024")
  - `term_type` (required): Term type (tm1, tm2, or tm3)
  - `limitCount` (optional): Number of students to return (default: 10)
- **Access**: Manager role required

### 2. Average Marks per Subject
- **Endpoint**: `GET /api/reports/avgmarks?year={year}&term_type={term_type}`
- **Description**: Get average marks for each subject by course and term
- **Parameters**:
  - `year` (required): Academic year (e.g., "2024")
  - `term_type` (required): Term type (tm1, tm2, or tm3)
- **Access**: Manager role required

### 3. Teacher Performance Report
- **Endpoint**: `GET /api/reports/teacherperformance`
- **Description**: Get average student marks for each teacher by subject
- **Access**: Manager role required

### 4. Student Progress Across Terms
- **Endpoint**: `GET /api/reports/studentprogress?year={year}`
- **Description**: Get term-wise marks (tm1, tm2, tm3) for each student grouped by subject
- **Parameters**:
  - `year` (required): Academic year (e.g., "2024")
- **Access**: Manager role required

### 5. Low Performing Subjects
- **Endpoint**: `GET /api/reports/lowperformingsubjects?year={year}&threshold={threshold}`
- **Description**: Get subjects with average marks below a specified threshold
- **Parameters**:
  - `year` (required): Academic year (e.g., "2024")
  - `threshold` (optional): Performance threshold (default: 40)
- **Access**: Manager role required

### 6. Top Performing Courses
- **Endpoint**: `GET /api/reports/topcourses?year={year}&term_type={term_type}`
- **Description**: Get courses with highest average marks for a specific term and year
- **Parameters**:
  - `year` (required): Academic year (e.g., "2024")
  - `term_type` (required): Term type (tm1, tm2, or tm3)
- **Access**: Manager role required

## Authentication

All endpoints require:
- Authorization header with valid JWT token
- Manager role privileges

## Error Handling

The service provides detailed error responses for:
- Missing authorization
- Insufficient privileges
- Invalid parameters
- Database errors
- Internal server errors

## Database Dependencies

The service relies on the following database tables:
- `student_test_course_subject` (marks data)
- `student` (student information)
- `subject` (subject information)
- `course` (course information)
- `test` (test information)
- `user` (user information)
- `profile` (user profile information)
- `subject_course_teacher` (teacher assignments)

All queries respect soft delete functionality by filtering out records where `deleted_at IS NOT NULL`.
