# User Management System

This document describes the User Management system that has been added to the School Performance Panel officer dashboard.

## Features Added

### 1. Officer Dashboard Card
- Added a new "Users" card to the officer dashboard
- Card icon: 👤
- Description: "Manage user accounts and profiles"
- Links to `/users` route

### 2. User Management Page (`/users`)
The user management page provides comprehensive CRUD operations for managing users:

#### Features:
- **Add New User**: Create new user accounts with profiles
- **Edit User**: Update existing user information (except email)
- **Delete User**: Soft delete users (can be restored)
- **Restore User**: Restore soft-deleted users
- **Search Users**: Search users by email address
- **View Active Users**: List all active users
- **View Deleted Users**: List all soft-deleted users

#### User Form Fields:
- **Email** (required, cannot be changed after creation)
- **Password** (required for new users only)
- **Role** (required): Manager, Teacher, Officer, Guest
- **Full Name** (required)
- **Phone Number** (optional, with format validation)
- **Date of Birth** (optional, with date validation)

### 3. API Integration
The frontend integrates with the Ballerina user service API:

#### API Endpoints:
- `GET /api/user` - Get all active users
- `GET /api/user/{id}` - Get user by ID
- `POST /api/user` - Add new user
- `PUT /api/user/{id}` - Update user
- `DELETE /api/user/{id}` - Soft delete user
- `POST /api/user/{id}/restore` - Restore deleted user
- `GET /api/user/deleted` - Get deleted users
- `GET /api/user/search?email={term}` - Search users by email

### 4. Security Features
- Authorization token automatically included in all requests
- Redirects to login if token expires
- Form validation with clear error messages
- Confirmation dialogs for destructive operations

## File Structure

```
src/
├── components/
│   └── users/
│       ├── UserManagement.jsx      # Main management page
│       ├── UserManagement.css      # Styling for user management
│       ├── UserForm.jsx            # Form for add/edit user
│       └── UserList.jsx            # List component for displaying users
├── services/
│   └── userService.js              # API service for user operations
└── App.jsx                         # Updated with /users route
```

## Styling Features

### Visual Design:
- **High contrast colors** for excellent visibility
- **Bold borders** (3px) on form inputs for clear definition
- **Color-coded role badges** for easy role identification:
  - Manager: Blue (#1565c0)
  - Teacher: Purple (#7b1fa2)
  - Officer: Green (#2e7d32)
  - Guest: Orange (#ef6c00)
- **Professional gradient backgrounds**
- **Responsive design** for mobile devices

### Form Input Styling:
- Black borders with blue focus states
- Large padding for comfortable interaction
- Clear error states with red backgrounds
- Disabled state styling for read-only fields
- Custom select dropdown styling

## User Roles

The system supports four user roles with different access levels:

1. **Manager**: Full administrative access
2. **Teacher**: Teaching-related functions
3. **Officer**: Administrative functions (current user role)
4. **Guest**: Limited access

## Usage Instructions

### Accessing User Management:
1. Log in as an Officer
2. Navigate to Officer Dashboard
3. Click on the "Users" card
4. You'll be redirected to `/users` page

### Adding a New User:
1. Click "Add New User" button
2. Fill in the required fields (email, password, role, name)
3. Optionally add phone number and date of birth
4. Click "Add User" to submit

### Editing a User:
1. Find the user in the Active Users list
2. Click "Edit" button next to the user
3. Modify the fields (note: email cannot be changed)
4. Click "Update User" to save changes

### Deleting/Restoring Users:
1. For active users: Click "Delete" button and confirm
2. For deleted users: Switch to "Deleted Users" tab and click "Restore"

### Searching Users:
1. Use the search box in the search section
2. Type any part of an email address
3. Results will appear automatically as you type

## Testing

A PowerShell test script is provided (`test_user_management_api.ps1`) to test all API endpoints. Usage:

```powershell
.\test_user_management_api.ps1 -BaseUrl "http://localhost:8080" -Token "your_jwt_token"
```

## Technical Notes

- All operations require Officer role authentication
- The system uses JWT tokens for authentication
- Soft delete functionality preserves data integrity
- Email addresses must be unique across all users
- Phone numbers are validated for international format
- Date of birth must be in the past
