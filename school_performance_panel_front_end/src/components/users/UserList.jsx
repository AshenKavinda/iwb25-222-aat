import React from 'react';

const UserList = ({ users, onEdit, onDelete, onRestore, showActions = false, isDeleted = false }) => {
  if (!users || users.length === 0) {
    return (
      <div className="empty-state">
        <div className="empty-icon">👤</div>
        <h3>No users found</h3>
        <p>{isDeleted ? 'No deleted users available' : 'No active users available'}</p>
      </div>
    );
  }

  const formatDate = (dateString) => {
    if (!dateString) return 'N/A';
    try {
      return new Date(dateString).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
      });
    } catch {
      return 'Invalid Date';
    }
  };

  const formatRole = (role) => {
    const roleMap = {
      'manager': 'Manager',
      'teacher': 'Teacher',
      'officer': 'Officer',
      'guest': 'Guest'
    };
    return roleMap[role] || role;
  };

  const getRoleBadgeClass = (role) => {
    const roleClasses = {
      'manager': 'role-badge role-manager',
      'teacher': 'role-badge role-teacher',
      'officer': 'role-badge role-officer',
      'guest': 'role-badge role-guest'
    };
    return roleClasses[role] || 'role-badge';
  };

  return (
    <div className="user-list">
      <div className="table-container">
        <table className="user-table">
          <thead>
            <tr>
              <th>User ID</th>
              <th>Email</th>
              <th>Name</th>
              <th>Role</th>
              <th>Phone</th>
              <th>Date of Birth</th>
              <th>{isDeleted ? 'Deleted At' : 'Created At'}</th>
              {showActions && <th>Actions</th>}
            </tr>
          </thead>
          <tbody>
            {users.map((userWithProfile) => {
              const user = userWithProfile.user;
              const profile = userWithProfile.profile;
              
              return (
                <tr key={user.user_id} className={isDeleted ? 'deleted-row' : ''}>
                  <td>
                    <span className="user-id">#{user.user_id}</span>
                  </td>
                  <td>
                    <div className="user-email">
                      <span className="email">{user.email}</span>
                    </div>
                  </td>
                  <td>
                    <div className="user-name">
                      <span className="name">{profile?.name || 'N/A'}</span>
                    </div>
                  </td>
                  <td>
                    <span className={getRoleBadgeClass(user.role)}>
                      {formatRole(user.role)}
                    </span>
                  </td>
                  <td>
                    <span className="phone">
                      {profile?.phone_number || 'N/A'}
                    </span>
                  </td>
                  <td>
                    <span className="dob">
                      {profile?.dob ? formatDate(profile.dob) : 'N/A'}
                    </span>
                  </td>
                  <td>
                    <span className={`date ${isDeleted ? 'deleted' : ''}`}>
                      {formatDate(isDeleted ? user.deleted_at : user.created_at)}
                    </span>
                  </td>
                  {showActions && (
                    <td>
                      <div className="action-buttons">
                        {!isDeleted ? (
                          <>
                            <button
                              onClick={() => onEdit(userWithProfile)}
                              className="btn btn-sm btn-secondary"
                              title="Edit User"
                            >
                              ✏️ Edit
                            </button>
                            <button
                              onClick={() => onDelete(user.user_id)}
                              className="btn btn-sm btn-danger"
                              title="Delete User"
                            >
                              🗑️ Delete
                            </button>
                          </>
                        ) : (
                          <button
                            onClick={() => onRestore(user.user_id)}
                            className="btn btn-sm btn-success"
                            title="Restore User"
                          >
                            ↩️ Restore
                          </button>
                        )}
                      </div>
                    </td>
                  )}
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
      
      <div className="table-footer">
        <p>{users.length} {isDeleted ? 'deleted' : 'active'} user{users.length !== 1 ? 's' : ''} found</p>
      </div>
    </div>
  );
};

export default UserList;
