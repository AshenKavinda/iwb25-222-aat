import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../../hooks/useAuth';
import studentService from '../../services/studentService';
import StudentForm from './StudentForm';
import StudentList from './StudentList';
import './StudentManagement.css';

const StudentManagement = () => {
  const { user } = useAuth();
  const [students, setStudents] = useState([]);
  const [deletedStudents, setDeletedStudents] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [activeTab, setActiveTab] = useState('active'); // 'active' or 'deleted'
  const [showForm, setShowForm] = useState(false);
  const [editingStudent, setEditingStudent] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [searchResults, setSearchResults] = useState([]);
  const [isSearching, setIsSearching] = useState(false);

  useEffect(() => {
    loadStudents();
  }, []);

  const loadStudents = async () => {
    try {
      setLoading(true);
      setError('');
      
      const [activeResponse, deletedResponse] = await Promise.all([
        studentService.getAllStudents(),
        studentService.getDeletedStudents()
      ]);

      setStudents(activeResponse.data || []);
      setDeletedStudents(deletedResponse.data || []);
    } catch (err) {
      console.error('Error loading students:', err);
      setError(err.response?.data?.message || 'Failed to load students');
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
      const response = await studentService.searchStudentsByName(term);
      setSearchResults(response.data || []);
    } catch (err) {
      console.error('Error searching students:', err);
      setError(err.response?.data?.message || 'Failed to search students');
      setSearchResults([]);
    } finally {
      setIsSearching(false);
    }
  };

  const handleAddStudent = async (studentData) => {
    try {
      setError('');
      setSuccess('');
      
      // Add current user's ID as the officer
      const dataWithUserId = {
        ...studentData,
        user_id: user.user_id
      };

      await studentService.addStudent(dataWithUserId);
      setSuccess('Student added successfully!');
      setShowForm(false);
      loadStudents();
    } catch (err) {
      console.error('Error adding student:', err);
      setError(err.response?.data?.message || 'Failed to add student');
    }
  };

  const handleUpdateStudent = async (studentData) => {
    try {
      setError('');
      setSuccess('');
      
      await studentService.updateStudent(editingStudent.student_id, studentData);
      setSuccess('Student updated successfully!');
      setEditingStudent(null);
      setShowForm(false);
      loadStudents();
    } catch (err) {
      console.error('Error updating student:', err);
      setError(err.response?.data?.message || 'Failed to update student');
    }
  };

  const handleDeleteStudent = async (studentId) => {
    if (!window.confirm('Are you sure you want to delete this student?')) {
      return;
    }

    try {
      setError('');
      setSuccess('');
      
      await studentService.deleteStudent(studentId);
      setSuccess('Student deleted successfully!');
      loadStudents();
    } catch (err) {
      console.error('Error deleting student:', err);
      setError(err.response?.data?.message || 'Failed to delete student');
    }
  };

  const handleRestoreStudent = async (studentId) => {
    if (!window.confirm('Are you sure you want to restore this student?')) {
      return;
    }

    try {
      setError('');
      setSuccess('');
      
      await studentService.restoreStudent(studentId);
      setSuccess('Student restored successfully!');
      loadStudents();
    } catch (err) {
      console.error('Error restoring student:', err);
      setError(err.response?.data?.message || 'Failed to restore student');
    }
  };

  const handleEditStudent = (student) => {
    setEditingStudent(student);
    setShowForm(true);
  };

  const handleCancelForm = () => {
    setShowForm(false);
    setEditingStudent(null);
  };

  const clearMessages = () => {
    setError('');
    setSuccess('');
  };

  if (loading) {
    return (
      <div className="loading-container">
        <div className="loading-spinner"></div>
        <p>Loading students...</p>
      </div>
    );
  }

  return (
    <div className="student-management">
      <header className="page-header">
        <div className="header-content">
          <div className="breadcrumb">
            <Link to="/dashboard" className="breadcrumb-link">Dashboard</Link>
            <span className="breadcrumb-separator">›</span>
            <span className="breadcrumb-current">Students</span>
          </div>
          <h1>Student Management</h1>
          <p>Manage student records and enrollments</p>
        </div>
        <div className="header-actions">
          <button 
            onClick={() => setShowForm(true)} 
            className="btn btn-primary"
            disabled={showForm}
          >
            Add New Student
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

      {/* Student Form */}
      {showForm && (
        <div className="form-section">
          <h2>{editingStudent ? 'Edit Student' : 'Add New Student'}</h2>
          <StudentForm
            student={editingStudent}
            onSubmit={editingStudent ? handleUpdateStudent : handleAddStudent}
            onCancel={handleCancelForm}
          />
        </div>
      )}

      {/* Search Section */}
      <div className="search-section">
        <h3>Search Students</h3>
        <div className="search-input-group">
          <input
            type="text"
            placeholder="Search by student name..."
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
            <StudentList
              students={searchResults}
              onEdit={handleEditStudent}
              onDelete={handleDeleteStudent}
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
          Active Students ({students.length})
        </button>
        <button 
          className={`tab-button ${activeTab === 'deleted' ? 'active' : ''}`}
          onClick={() => setActiveTab('deleted')}
        >
          Deleted Students ({deletedStudents.length})
        </button>
      </div>

      {/* Student Lists */}
      <div className="tab-content">
        {activeTab === 'active' && (
          <div className="tab-panel">
            <div className="section-header">
              <h3>Active Students</h3>
              <p>{students.length} students found</p>
            </div>
            <StudentList
              students={students}
              onEdit={handleEditStudent}
              onDelete={handleDeleteStudent}
              showActions={true}
            />
          </div>
        )}

        {activeTab === 'deleted' && (
          <div className="tab-panel">
            <div className="section-header">
              <h3>Deleted Students</h3>
              <p>{deletedStudents.length} deleted students found</p>
            </div>
            <StudentList
              students={deletedStudents}
              onRestore={handleRestoreStudent}
              showActions={true}
              isDeleted={true}
            />
          </div>
        )}
      </div>
    </div>
  );
};

export default StudentManagement;
