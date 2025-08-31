import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import userService from '../../services/userService';
import UserForm from './UserForm';
import UserList from './UserList';
import './UserManagement.css';

const UserManagement = () => {
  const [users, setUsers] = useState([]);
  const [deletedUsers, setDeletedUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [activeTab, setActiveTab] = useState('active'); // 'active' or 'deleted'
  const [showForm, setShowForm] = useState(false);
  const [editingUser, setEditingUser] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [searchResults, setSearchResults] = useState([]);
  const [isSearching, setIsSearching] = useState(false);

  useEffect(() => {
    loadUsers();
  }, []);

  const loadUsers = async () => {
    try {
      setLoading(true);
      setError('');
      
      const [activeResponse, deletedResponse] = await Promise.all([
        userService.getAllUsers(),
        userService.getDeletedUsers()
      ]);

      setUsers(activeResponse.data || []);
      setDeletedUsers(deletedResponse.data || []);
    } catch (err) {
      console.error('Error loading users:', err);
      setError(err.response?.data?.message || 'Failed to load users');
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = async (term) => {
    if (!term.trim()) {
      setSearchResults([]);
      setIsSearching(false);
      return;
    }

    try {
      setIsSearching(true);
      const response = await userService.searchUsersByEmail(term);
      setSearchResults(response.data || []);
    } catch (err) {
      console.error('Error searching users:', err);
      setError(err.response?.data?.message || 'Failed to search users');
      setSearchResults([]);
    } finally {
      setIsSearching(false);
    }
  };

  const handleAddUser = async (userData) => {
    try {
      setError('');
      setSuccess('');
      
      await userService.addUser(userData);
      setSuccess('User added successfully!');
      setShowForm(false);
      loadUsers();
    } catch (err) {
      console.error('Error adding user:', err);
      setError(err.response?.data?.message || 'Failed to add user');
    }
  };

  const handleUpdateUser = async (userData) => {
    try {
      setError('');
      setSuccess('');
      
      await userService.updateUser(editingUser.user.user_id, userData);
      setSuccess('User updated successfully!');
      setEditingUser(null);
      setShowForm(false);
      loadUsers();
    } catch (err) {
      console.error('Error updating user:', err);
      setError(err.response?.data?.message || 'Failed to update user');
    }
  };

  const handleDeleteUser = async (userId) => {
    if (!window.confirm('Are you sure you want to delete this user?')) {
      return;
    }

    try {
      setError('');
      setSuccess('');
      
      await userService.deleteUser(userId);
      setSuccess('User deleted successfully!');
      loadUsers();
    } catch (err) {
      console.error('Error deleting user:', err);
      setError(err.response?.data?.message || 'Failed to delete user');
    }
  };

  const handleRestoreUser = async (userId) => {
    if (!window.confirm('Are you sure you want to restore this user?')) {
      return;
    }

    try {
      setError('');
      setSuccess('');
      
      await userService.restoreUser(userId);
      setSuccess('User restored successfully!');
      loadUsers();
    } catch (err) {
      console.error('Error restoring user:', err);
      setError(err.response?.data?.message || 'Failed to restore user');
    }
  };

  const handleEditUser = (userWithProfile) => {
    setEditingUser(userWithProfile);
    setShowForm(true);
  };

  const handleCancelForm = () => {
    setShowForm(false);
    setEditingUser(null);
  };

  const clearMessages = () => {
    setError('');
    setSuccess('');
  };

  if (loading) {
    return (
      <div className="loading-container">
        <div className="loading-spinner"></div>
        <p>Loading users...</p>
      </div>
    );
  }

  return (
    <div className="user-management">
      <header className="page-header">
        <div className="header-content">
          <div className="breadcrumb">
            <Link to="/dashboard" className="breadcrumb-link">Dashboard</Link>
            <span className="breadcrumb-separator">›</span>
            <span className="breadcrumb-current">Users</span>
          </div>
          <h1>User Management</h1>
          <p>Manage user accounts and profiles</p>
        </div>
        <div className="header-actions">
          <button 
            onClick={() => setShowForm(true)} 
            className="btn btn-primary"
            disabled={showForm}
          >
            Add New User
          </button>
        </div>
      </header>

      {/* Messages */}
      {error && (
        <div className="alert alert-error">
          {error}
          <button onClick={clearMessages} className="alert-close">×</button>
        </div>
      )}
      {success && (
        <div className="alert alert-success">
          {success}
          <button onClick={clearMessages} className="alert-close">×</button>
        </div>
      )}

      {/* User Form */}
      {showForm && (
        <div className="form-section">
          <h2>{editingUser ? 'Edit User' : 'Add New User'}</h2>
          <UserForm
            user={editingUser}
            onSubmit={editingUser ? handleUpdateUser : handleAddUser}
            onCancel={handleCancelForm}
          />
        </div>
      )}

      {/* Search Section */}
      <div className="search-section">
        <h3>Search Users</h3>
        <div className="search-input-group">
          <input
            type="text"
            placeholder="Search by email address..."
            value={searchTerm}
            onChange={(e) => {
              setSearchTerm(e.target.value);
              handleSearch(e.target.value);
            }}
            className="search-input"
          />
          {isSearching && <div className="search-spinner">🔍</div>}
        </div>
        
        {searchResults.length > 0 && (
          <div className="search-results">
            <h4>Search Results ({searchResults.length})</h4>
            <UserList
              users={searchResults}
              onEdit={handleEditUser}
              onDelete={handleDeleteUser}
              showActions={true}
            />
          </div>
        )}
      </div>

      {/* Tab Navigation */}
      <div className="tab-navigation">
        <button 
          className={`tab-button ${activeTab === 'active' ? 'active' : ''}`}
          onClick={() => setActiveTab('active')}
        >
          Active Users ({users.length})
        </button>
        <button 
          className={`tab-button ${activeTab === 'deleted' ? 'active' : ''}`}
          onClick={() => setActiveTab('deleted')}
        >
          Deleted Users ({deletedUsers.length})
        </button>
      </div>

      {/* User Lists */}
      <div className="tab-content">
        {activeTab === 'active' && (
          <div className="tab-panel">
            <div className="section-header">
              <h3>Active Users</h3>
              <p>{users.length} users found</p>
            </div>
            <UserList
              users={users}
              onEdit={handleEditUser}
              onDelete={handleDeleteUser}
              showActions={true}
            />
          </div>
        )}

        {activeTab === 'deleted' && (
          <div className="tab-panel">
            <div className="section-header">
              <h3>Deleted Users</h3>
              <p>{deletedUsers.length} deleted users found</p>
            </div>
            <UserList
              users={deletedUsers}
              onRestore={handleRestoreUser}
              showActions={true}
              isDeleted={true}
            />
          </div>
        )}
      </div>
    </div>
  );
};

export default UserManagement;
