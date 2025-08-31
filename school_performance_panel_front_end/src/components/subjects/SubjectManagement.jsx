import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../../hooks/useAuth';
import subjectService from '../../services/subjectService';
import SubjectForm from './SubjectForm';
import SubjectList from './SubjectList';
import './SubjectManagement.css';

const SubjectManagement = () => {
  const { user } = useAuth();
  const [subjects, setSubjects] = useState([]);
  const [deletedSubjects, setDeletedSubjects] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [activeTab, setActiveTab] = useState('active'); // 'active' or 'deleted'
  const [showForm, setShowForm] = useState(false);
  const [editingSubject, setEditingSubject] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [searchResults, setSearchResults] = useState([]);
  const [isSearching, setIsSearching] = useState(false);

  useEffect(() => {
    loadSubjects();
  }, []);

  const loadSubjects = async () => {
    try {
      setLoading(true);
      setError('');
      
      const [activeResponse, deletedResponse] = await Promise.all([
        subjectService.getAllSubjects(),
        subjectService.getDeletedSubjects()
      ]);

      setSubjects(activeResponse.data || []);
      setDeletedSubjects(deletedResponse.data || []);
    } catch (err) {
      console.error('Error loading subjects:', err);
      setError(err.response?.data?.message || 'Failed to load subjects');
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
      const response = await subjectService.searchSubjectsByName(term);
      setSearchResults(response.data || []);
    } catch (err) {
      console.error('Error searching subjects:', err);
      setError(err.response?.data?.message || 'Failed to search subjects');
      setSearchResults([]);
    } finally {
      setIsSearching(false);
    }
  };

  const handleAddSubject = async (subjectData) => {
    try {
      setError('');
      setSuccess('');
      
      // Add current user's ID as the officer
      const dataWithUserId = {
        ...subjectData,
        user_id: user.user_id
      };

      await subjectService.addSubject(dataWithUserId);
      setSuccess('Subject added successfully!');
      setShowForm(false);
      loadSubjects();
    } catch (err) {
      console.error('Error adding subject:', err);
      setError(err.response?.data?.message || 'Failed to add subject');
    }
  };

  const handleUpdateSubject = async (subjectData) => {
    try {
      setError('');
      setSuccess('');
      
      await subjectService.updateSubject(editingSubject.subject_id, subjectData);
      setSuccess('Subject updated successfully!');
      setEditingSubject(null);
      setShowForm(false);
      loadSubjects();
    } catch (err) {
      console.error('Error updating subject:', err);
      setError(err.response?.data?.message || 'Failed to update subject');
    }
  };

  const handleDeleteSubject = async (subjectId) => {
    if (!window.confirm('Are you sure you want to delete this subject?')) {
      return;
    }

    try {
      setError('');
      setSuccess('');
      
      await subjectService.deleteSubject(subjectId);
      setSuccess('Subject deleted successfully!');
      loadSubjects();
    } catch (err) {
      console.error('Error deleting subject:', err);
      setError(err.response?.data?.message || 'Failed to delete subject');
    }
  };

  const handleRestoreSubject = async (subjectId) => {
    if (!window.confirm('Are you sure you want to restore this subject?')) {
      return;
    }

    try {
      setError('');
      setSuccess('');
      
      await subjectService.restoreSubject(subjectId);
      setSuccess('Subject restored successfully!');
      loadSubjects();
    } catch (err) {
      console.error('Error restoring subject:', err);
      setError(err.response?.data?.message || 'Failed to restore subject');
    }
  };

  const handleEditSubject = (subject) => {
    setEditingSubject(subject);
    setShowForm(true);
  };

  const handleCancelForm = () => {
    setShowForm(false);
    setEditingSubject(null);
  };

  const clearMessages = () => {
    setError('');
    setSuccess('');
  };

  if (loading) {
    return (
      <div className="loading-container">
        <div className="loading-spinner"></div>
        <p>Loading subjects...</p>
      </div>
    );
  }

  return (
    <div className="subject-management">
      <header className="page-header">
        <div className="header-content">
          <div className="breadcrumb">
            <Link to="/dashboard" className="breadcrumb-link">Dashboard</Link>
            <span className="breadcrumb-separator">›</span>
            <span className="breadcrumb-current">Subjects</span>
          </div>
          <h1>Subject Management</h1>
          <p>Manage subjects and curriculum</p>
        </div>
        <div className="header-actions">
          <button 
            onClick={() => setShowForm(true)} 
            className="btn btn-primary"
            disabled={showForm}
          >
            Add New Subject
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

      {/* Subject Form */}
      {showForm && (
        <div className="form-section">
          <h2>{editingSubject ? 'Edit Subject' : 'Add New Subject'}</h2>
          <SubjectForm
            subject={editingSubject}
            onSubmit={editingSubject ? handleUpdateSubject : handleAddSubject}
            onCancel={handleCancelForm}
          />
        </div>
      )}

      {/* Search Section */}
      <div className="search-section">
        <h3>Search Subjects</h3>
        <div className="search-input-group">
          <input
            type="text"
            placeholder="Search by subject name..."
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
            <SubjectList
              subjects={searchResults}
              onEdit={handleEditSubject}
              onDelete={handleDeleteSubject}
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
          Active Subjects ({subjects.length})
        </button>
        <button 
          className={`tab-button ${activeTab === 'deleted' ? 'active' : ''}`}
          onClick={() => setActiveTab('deleted')}
        >
          Deleted Subjects ({deletedSubjects.length})
        </button>
      </div>

      {/* Subject Lists */}
      <div className="tab-content">
        {activeTab === 'active' && (
          <div className="tab-panel">
            <div className="section-header">
              <h3>Active Subjects</h3>
              <p>{subjects.length} subjects found</p>
            </div>
            <SubjectList
              subjects={subjects}
              onEdit={handleEditSubject}
              onDelete={handleDeleteSubject}
              showActions={true}
            />
          </div>
        )}

        {activeTab === 'deleted' && (
          <div className="tab-panel">
            <div className="section-header">
              <h3>Deleted Subjects</h3>
              <p>{deletedSubjects.length} deleted subjects found</p>
            </div>
            <SubjectList
              subjects={deletedSubjects}
              onRestore={handleRestoreSubject}
              showActions={true}
              isDeleted={true}
            />
          </div>
        )}
      </div>
    </div>
  );
};

export default SubjectManagement;
