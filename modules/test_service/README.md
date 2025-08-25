# Test Service

This module provides REST API endpoints for managing tests in the school performance system.

## Features

- **Add Test**: Create new tests with validation for test type (tm1, tm2, tm3) and officer role
- **Update Test**: Modify existing test details
- **Soft Delete**: Mark tests as deleted without permanent removal
- **Restore**: Restore previously deleted tests
- **Get All Tests**: Retrieve all active tests
- **Get Test by ID**: Retrieve specific test by its ID
- **Filter by Type**: Filter tests by type (tm1, tm2, tm3)
- **Filter by Year**: Filter tests by academic year
- **Search by Name**: Search tests by name pattern
- **Role-based Access Control**: Only officers can perform operations

## API Endpoints

### Test Management
- `POST /api/test` - Add new test (Officer only)
- `PUT /api/test/{test_id}` - Update test (Officer only)
- `DELETE /api/test/{test_id}` - Soft delete test (Officer only)
- `POST /api/test/{test_id}/restore` - Restore test (Officer only)

### Test Retrieval
- `GET /api/test` - Get all tests (Officer only)
- `GET /api/test/{test_id}` - Get test by ID (Officer only)
- `GET /api/test/deleted` - Get deleted tests (Officer only)

### Filtering and Search
- `GET /api/test/types/{type}` - Filter tests by type (tm1/tm2/tm3) (Officer only)
- `GET /api/test/year/{year}` - Filter tests by year (Officer only)
- `GET /api/test/search/name/{name}` - Search tests by name (Officer only)
- `GET /api/test/years` - Get available years (Officer only)

## Test Types

The system supports three test types:
- `tm1` - Term Test 1
- `tm2` - Term Test 2  
- `tm3` - Term Test 3

## Data Structure

```json
{
    "test_id": 1,
    "t_name": "Mathematics Term Test 1",
    "t_type": "tm1",
    "year": "2024",
    "user_id": 5,
    "created_at": "2024-01-15T10:30:00Z",
    "updated_at": "2024-01-15T10:30:00Z",
    "deleted_at": null
}
```

## Validation Rules

1. **Test Type**: Must be one of the valid ENUM values (tm1, tm2, tm3)
2. **User Role**: Only users with 'officer' role can perform test operations
3. **User Existence**: User ID must exist and not be deleted
4. **Soft Delete**: Tests are marked as deleted, not permanently removed

## Error Handling

The service returns appropriate error messages for:
- Invalid test types
- Unauthorized access (non-officer users)
- Test not found scenarios
- Database operation failures
