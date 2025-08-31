import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../../hooks/useAuth';
import courseService from '../../services/courseService';
import CourseForm from './CourseForm';
import CourseList from './CourseList';
import './CourseManagement.css';

const CourseManagement = () => {
  const { user } = useAuth();
  const [courses, setCourses] = useState([]);
  const [deletedCourses, setDeletedCourses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [activeTab, setActiveTab] = useState('active'); // 'active' or 'deleted'
  const [showForm, setShowForm] = useState(false);
  const [editingCourse, setEditingCourse] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [searchYear, setSearchYear] = useState('');
  const [searchResults, setSearchResults] = useState([]);
  const [isSearching, setIsSearching] = useState(false);
  const [availableYears, setAvailableYears] = useState([]);

  useEffect(() => {
    loadCourses();
    loadAvailableYears();
  }, []);

  const loadCourses = async () => {
    try {
      setLoading(true);
      setError('');
      
      const [activeResponse, deletedResponse] = await Promise.all([
        courseService.getAllCourses(),
        courseService.getDeletedCourses()
      ]);

      setCourses(activeResponse.data || []);
      setDeletedCourses(deletedResponse.data || []);
    } catch (err) {
      console.error('Error loading courses:', err);
      setError(err.response?.data?.message || 'Failed to load courses');
    } finally {
      setLoading(false);
    }
  };

  const loadAvailableYears = async () => {
    try {
      const response = await courseService.getAvailableYears();
      setAvailableYears(response.data || []);
    } catch (err) {
      console.error('Error loading available years:', err);
    }
  };

  const handleSearch = async () => {
    if (!searchTerm.trim() && !searchYear.trim()) {
      setSearchResults([]);
      setIsSearching(false);
      return;
    }

    try {
      setIsSearching(true);
      let response;

      if (searchTerm.trim() && searchYear.trim()) {
        // Search by both name and year
        response = await courseService.searchCoursesByNameAndYear(searchTerm.trim(), searchYear.trim());
      } else if (searchTerm.trim()) {
        // Search by name only
        response = await courseService.searchCoursesByName(searchTerm.trim());
      } else if (searchYear.trim()) {
        // Search by year only
        response = await courseService.searchCoursesByYear(searchYear.trim());
      }

      setSearchResults(response.data || []);
    } catch (err) {
      console.error('Error searching courses:', err);
      setError(err.response?.data?.message || 'Failed to search courses');
      setSearchResults([]);
    } finally {
      setIsSearching(false);
    }
  };

  const handleAddCourse = async (courseData) => {
    try {
      setError('');
      setSuccess('');
      
      // Add current user's ID as the officer
      const dataWithUserId = {
        ...courseData,
        user_id: user.user_id
      };

      await courseService.addCourse(dataWithUserId);
      setSuccess('Course added successfully!');
      setShowForm(false);
      loadCourses();
      loadAvailableYears(); // Refresh available years
    } catch (err) {
      console.error('Error adding course:', err);
      setError(err.response?.data?.message || 'Failed to add course');
    }
  };

  const handleUpdateCourse = async (courseData) => {
    try {
      setError('');
      setSuccess('');
      
      await courseService.updateCourse(editingCourse.course_id, courseData);
      setSuccess('Course updated successfully!');
      setEditingCourse(null);
      setShowForm(false);
      loadCourses();
      loadAvailableYears(); // Refresh available years
    } catch (err) {
      console.error('Error updating course:', err);
      setError(err.response?.data?.message || 'Failed to update course');
    }
  };

  const handleDeleteCourse = async (courseId) => {
    if (!window.confirm('Are you sure you want to delete this course?')) {
      return;
    }

    try {
      setError('');
      setSuccess('');
      
      await courseService.deleteCourse(courseId);
      setSuccess('Course deleted successfully!');
      loadCourses();
    } catch (err) {
      console.error('Error deleting course:', err);
      setError(err.response?.data?.message || 'Failed to delete course');
    }
  };

  const handleRestoreCourse = async (courseId) => {
    if (!window.confirm('Are you sure you want to restore this course?')) {
      return;
    }

    try {
      setError('');
      setSuccess('');
      
      await courseService.restoreCourse(courseId);
      setSuccess('Course restored successfully!');
      loadCourses();
    } catch (err) {
      console.error('Error restoring course:', err);
      setError(err.response?.data?.message || 'Failed to restore course');
    }
  };

  const handleEditCourse = (course) => {
    setEditingCourse(course);
    setShowForm(true);
  };

  const handleCancelForm = () => {
    setShowForm(false);
    setEditingCourse(null);
  };

  const clearMessages = () => {
    setError('');
    setSuccess('');
  };

  const clearSearch = () => {
    setSearchTerm('');
    setSearchYear('');
    setSearchResults([]);
    setIsSearching(false);
  };

  if (loading) {
    return (
      <div className="loading-container">
        <div className="loading-spinner"></div>
        <p>Loading courses...</p>
      </div>
    );
  }

  return (
    <div className="course-management">
      <header className="page-header">
        <div className="header-content">
          <div className="breadcrumb">
            <Link to="/dashboard" className="breadcrumb-link">Dashboard</Link>
            <span className="breadcrumb-separator">›</span>
            <span className="breadcrumb-current">Courses</span>
          </div>
          <h1>Course Management</h1>
          <p>Manage courses and academic programs</p>
        </div>
        <div className="header-actions">
          <button 
            onClick={() => setShowForm(true)} 
            className="btn btn-primary"
            disabled={showForm}
          >
            Add New Course
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

      {/* Course Form */}
      {showForm && (
        <div className="form-section">
          <h2>{editingCourse ? 'Edit Course' : 'Add New Course'}</h2>
          <CourseForm
            course={editingCourse}
            onSubmit={editingCourse ? handleUpdateCourse : handleAddCourse}
            onCancel={handleCancelForm}
          />
        </div>
      )}

      {/* Search Section */}
      <div className="search-section">
        <h3>Search Courses</h3>
        <div className="search-form">
          <div className="search-inputs">
            <div className="search-input-group">
              <input
                type="text"
                placeholder="Search by course name..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="search-input"
              />
            </div>
            <div className="search-input-group">
              <select
                value={searchYear}
                onChange={(e) => setSearchYear(e.target.value)}
                className="search-input"
              >
                <option value="">Select year...</option>
                {availableYears.map(year => (
                  <option key={year} value={year}>{year}</option>
                ))}
              </select>
            </div>
          </div>
          <div className="search-actions">
            <button 
              onClick={handleSearch}
              className="btn btn-primary"
              disabled={isSearching}
            >
              {isSearching ? '🔍 Searching...' : '🔍 Search'}
            </button>
            <button 
              onClick={clearSearch}
              className="btn btn-secondary"
              disabled={isSearching}
            >
              Clear
            </button>
          </div>
        </div>
        
        {searchResults.length > 0 && (
          <div className="search-results">
            <h4>Search Results ({searchResults.length})</h4>
            <CourseList
              courses={searchResults}
              onEdit={handleEditCourse}
              onDelete={handleDeleteCourse}
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
          Active Courses ({courses.length})
        </button>
        <button 
          className={`tab-button ${activeTab === 'deleted' ? 'active' : ''}`}
          onClick={() => setActiveTab('deleted')}
        >
          Deleted Courses ({deletedCourses.length})
        </button>
      </div>

      {/* Course Lists */}
      <div className="tab-content">
        {activeTab === 'active' && (
          <div className="tab-panel">
            <div className="section-header">
              <h3>Active Courses</h3>
              <p>{courses.length} courses found</p>
            </div>
            <CourseList
              courses={courses}
              onEdit={handleEditCourse}
              onDelete={handleDeleteCourse}
              showActions={true}
            />
          </div>
        )}

        {activeTab === 'deleted' && (
          <div className="tab-panel">
            <div className="section-header">
              <h3>Deleted Courses</h3>
              <p>{deletedCourses.length} deleted courses found</p>
            </div>
            <CourseList
              courses={deletedCourses}
              onRestore={handleRestoreCourse}
              showActions={true}
              isDeleted={true}
            />
          </div>
        )}
      </div>
    </div>
  );
};

export default CourseManagement;
