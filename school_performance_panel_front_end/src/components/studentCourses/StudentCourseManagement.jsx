import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../../hooks/useAuth';
import studentCourseService from '../../services/studentCourseService';
import studentService from '../../services/studentService';
import courseService from '../../services/courseService';
import StudentCourseForm from './StudentCourseForm';
import StudentCourseList from './StudentCourseList';
import './StudentCourseManagement.css';

const StudentCourseManagement = () => {
  const { user } = useAuth();
  const [enrollments, setEnrollments] = useState([]);
  const [students, setStudents] = useState([]);
  const [courses, setCourses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [showForm, setShowForm] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [searchResults, setSearchResults] = useState([]);
  const [isSearching, setIsSearching] = useState(false);
  const [activeTab, setActiveTab] = useState('all'); // 'all', 'by-student', 'by-course'
  const [filterStudentId, setFilterStudentId] = useState('');
  const [filterCourseId, setFilterCourseId] = useState('');
  const [selectedCourse, setSelectedCourse] = useState('');
  const [editingEnrollment, setEditingEnrollment] = useState(null);

  useEffect(() => {
    loadData();
  }, []);

  useEffect(() => {
    if (courses.length > 0) {
      loadAllEnrollments();
    }
  }, [courses]); // eslint-disable-line react-hooks/exhaustive-deps

  const loadData = async () => {
    try {
      setLoading(true);
      setError('');
      
      const [studentsResponse, coursesResponse] = await Promise.all([
        studentService.getAllStudents(),
        courseService.getAllCourses()
      ]);

      setStudents(studentsResponse.data || []);
      setCourses(coursesResponse.data || []);
    } catch (err) {
      console.error('Error loading data:', err);
      setError(err.response?.data?.message || 'Failed to load data');
    } finally {
      setLoading(false);
    }
  };

  const loadAllEnrollments = async () => {
    try {
      // Since there's no "get all" endpoint, we'll aggregate from all courses
      const allEnrollments = [];
      
      if (courses.length > 0) {
        const courseIds = courses.map(course => course.course_id).filter(Boolean);
        
        for (const courseId of courseIds) {
          try {
            const response = await studentCourseService.getStudentCoursesWithDetailsByCourseId(courseId);
            if (response.data) {
              allEnrollments.push(...response.data);
            }
          } catch (err) {
            // Continue with other courses if one fails
            console.warn(`Failed to load enrollments for course ${courseId}:`, err);
          }
        }
      }
      
      setEnrollments(allEnrollments);
    } catch (err) {
      console.error('Error loading enrollments:', err);
      setError('Failed to load enrollments');
    }
  };

  const handleFilterByStudent = async (studentId) => {
    if (!studentId) {
      setEnrollments([]);
      return;
    }

    try {
      setLoading(true);
      setError('');
      const response = await studentCourseService.getStudentCoursesWithDetailsByStudentId(parseInt(studentId));
      setEnrollments(response.data || []);
    } catch (err) {
      console.error('Error filtering by student:', err);
      setError(err.response?.data?.message || 'Failed to filter enrollments by student');
      setEnrollments([]);
    } finally {
      setLoading(false);
    }
  };

  const handleFilterByCourse = async (courseId) => {
    if (!courseId) {
      setEnrollments([]);
      return;
    }

    try {
      setLoading(true);
      setError('');
      const response = await studentCourseService.getStudentCoursesWithDetailsByCourseId(parseInt(courseId));
      setEnrollments(response.data || []);
    } catch (err) {
      console.error('Error filtering by course:', err);
      setError(err.response?.data?.message || 'Failed to filter enrollments by course');
      setEnrollments([]);
    } finally {
      setLoading(false);
    }
  };

  const handleSearchStudents = async (term) => {
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

  const handleEnrollStudents = async (courseId, studentIds) => {
    try {
      setError('');
      setSuccess('');
      
      await studentCourseService.addStudentsToCourse(courseId, studentIds, user.user_id);
      setSuccess('Students enrolled successfully!');
      setShowForm(false);
      
      // Refresh the current view
      if (activeTab === 'by-course' && filterCourseId) {
        handleFilterByCourse(filterCourseId);
      } else if (activeTab === 'by-student' && filterStudentId) {
        handleFilterByStudent(filterStudentId);
      } else {
        loadAllEnrollments();
      }
    } catch (err) {
      console.error('Error enrolling students:', err);
      setError(err.response?.data?.message || 'Failed to enroll students');
    }
  };

  const handleUpdateEnrollment = async (recordId, updateData) => {
    try {
      setError('');
      setSuccess('');
      
      await studentCourseService.updateStudentCourse(recordId, updateData);
      setSuccess('Enrollment updated successfully!');
      setEditingEnrollment(null);
      setShowForm(false);
      
      // Refresh the current view
      if (activeTab === 'by-course' && filterCourseId) {
        handleFilterByCourse(filterCourseId);
      } else if (activeTab === 'by-student' && filterStudentId) {
        handleFilterByStudent(filterStudentId);
      } else {
        loadAllEnrollments();
      }
    } catch (err) {
      console.error('Error updating enrollment:', err);
      setError(err.response?.data?.message || 'Failed to update enrollment');
    }
  };

  const handleDeleteEnrollment = async (recordId) => {
    if (!window.confirm('Are you sure you want to remove this student from the course?')) {
      return;
    }

    try {
      setError('');
      setSuccess('');
      
      await studentCourseService.deleteStudentCourse(recordId);
      setSuccess('Student removed from course successfully!');
      
      // Refresh the current view
      if (activeTab === 'by-course' && filterCourseId) {
        handleFilterByCourse(filterCourseId);
      } else if (activeTab === 'by-student' && filterStudentId) {
        handleFilterByStudent(filterStudentId);
      } else {
        loadAllEnrollments();
      }
    } catch (err) {
      console.error('Error deleting enrollment:', err);
      setError(err.response?.data?.message || 'Failed to remove student from course');
    }
  };

  const handleEditEnrollment = (enrollment) => {
    setEditingEnrollment(enrollment);
    setShowForm(true);
  };

  const handleCancelForm = () => {
    setShowForm(false);
    setEditingEnrollment(null);
    setSelectedCourse('');
  };

  const clearMessages = () => {
    setError('');
    setSuccess('');
  };

  const clearFilters = () => {
    setFilterStudentId('');
    setFilterCourseId('');
    setActiveTab('all');
    loadAllEnrollments();
  };

  if (loading) {
    return (
      <div className="loading-container">
        <div className="loading-spinner"></div>
        <p>Loading student course enrollments...</p>
      </div>
    );
  }

  return (
    <div className="student-course-management">
      <header className="page-header">
        <div className="header-content">
          <div className="breadcrumb">
            <Link to="/dashboard" className="breadcrumb-link">Dashboard</Link>
            <span className="breadcrumb-separator">›</span>
            <span className="breadcrumb-current">Student Courses</span>
          </div>
          <h1>Student Course Management</h1>
          <p>Manage student course enrollments and assignments</p>
        </div>
        <div className="header-actions">
          <button 
            onClick={() => setShowForm(true)} 
            className="btn btn-primary"
            disabled={showForm}
          >
            Enroll Students
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

      {/* Enrollment Form */}
      {showForm && (
        <div className="form-section">
          <h2>{editingEnrollment ? 'Edit Enrollment' : 'Enroll Students in Course'}</h2>
          <StudentCourseForm
            enrollment={editingEnrollment}
            students={students}
            courses={courses}
            selectedCourse={selectedCourse}
            onSubmit={editingEnrollment ? handleUpdateEnrollment : handleEnrollStudents}
            onCancel={handleCancelForm}
          />
        </div>
      )}

      {/* Tab Navigation */}
      <div className="tab-navigation">
        <button 
          className={`tab-button ${activeTab === 'all' ? 'active' : ''}`}
          onClick={() => {
            setActiveTab('all');
            loadAllEnrollments();
          }}
        >
          All Enrollments ({enrollments.length})
        </button>
        <button 
          className={`tab-button ${activeTab === 'by-student' ? 'active' : ''}`}
          onClick={() => setActiveTab('by-student')}
        >
          By Student
        </button>
        <button 
          className={`tab-button ${activeTab === 'by-course' ? 'active' : ''}`}
          onClick={() => setActiveTab('by-course')}
        >
          By Course
        </button>
      </div>

      {/* Filter Section */}
      {activeTab !== 'all' && (
        <div className="filters-section">
          <h3>Filter Enrollments</h3>
          <div className="filters-grid">
            {activeTab === 'by-student' && (
              <div className="filter-group">
                <label htmlFor="filterStudent" className="filter-label">Select Student</label>
                <select
                  id="filterStudent"
                  value={filterStudentId}
                  onChange={(e) => {
                    setFilterStudentId(e.target.value);
                    handleFilterByStudent(e.target.value);
                  }}
                  className="filter-select"
                >
                  <option value="">Select a student...</option>
                  {students.map(student => (
                    <option key={student.student_id} value={student.student_id}>
                      {student.full_name}
                    </option>
                  ))}
                </select>
              </div>
            )}

            {activeTab === 'by-course' && (
              <div className="filter-group">
                <label htmlFor="filterCourse" className="filter-label">Select Course</label>
                <select
                  id="filterCourse"
                  value={filterCourseId}
                  onChange={(e) => {
                    setFilterCourseId(e.target.value);
                    setSelectedCourse(e.target.value);
                    handleFilterByCourse(e.target.value);
                  }}
                  className="filter-select"
                >
                  <option value="">Select a course...</option>
                  {courses.map(course => (
                    <option key={course.course_id} value={course.course_id}>
                      {course.name} ({course.year})
                    </option>
                  ))}
                </select>
              </div>
            )}

            <div className="filter-actions">
              <button onClick={clearFilters} className="btn btn-secondary btn-sm">
                Clear Filters
              </button>
              {activeTab === 'by-course' && filterCourseId && (
                <button 
                  onClick={() => {
                    setSelectedCourse(filterCourseId);
                    setShowForm(true);
                  }} 
                  className="btn btn-primary btn-sm"
                >
                  Add Students to Course
                </button>
              )}
            </div>
          </div>
        </div>
      )}

      {/* Search Section */}
      {activeTab === 'all' && (
        <div className="search-section">
          <h3>Search Students</h3>
          <div className="search-input-group">
            <input
              type="text"
              placeholder="Search students by name..."
              value={searchTerm}
              onChange={(e) => {
                setSearchTerm(e.target.value);
                handleSearchStudents(e.target.value);
              }}
              className="search-input"
            />
            {isSearching && <div className="search-spinner">🔍</div>}
          </div>
          
          {searchResults.length > 0 && (
            <div className="search-results">
              <h4>Search Results ({searchResults.length})</h4>
              <div className="student-results">
                {searchResults.map(student => (
                  <div key={student.student_id} className="student-result-item">
                    <div className="student-info">
                      <h5>{student.full_name}</h5>
                      <p>Student ID: {student.student_id}</p>
                      <p>Parent NIC: {student.parent_nic}</p>
                    </div>
                    <button 
                      onClick={() => {
                        setFilterStudentId(student.student_id.toString());
                        setActiveTab('by-student');
                        handleFilterByStudent(student.student_id);
                      }}
                      className="btn btn-secondary btn-sm"
                    >
                      View Enrollments
                    </button>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      )}

      {/* Enrollments List */}
      <div className="enrollments-section">
        <div className="section-header">
          <h3>
            {(() => {
              if (activeTab === 'by-student' && filterStudentId) {
                const student = students.find(s => s.student_id.toString() === filterStudentId);
                return `Enrollments for ${student?.full_name || 'Selected Student'}`;
              }
              if (activeTab === 'by-course' && filterCourseId) {
                const course = courses.find(c => c.course_id.toString() === filterCourseId);
                return `Students in ${course?.name || 'Selected Course'}`;
              }
              return 'All Student Course Enrollments';
            })()}
          </h3>
          <p>{enrollments.length} enrollment{enrollments.length !== 1 ? 's' : ''} found</p>
        </div>
        <StudentCourseList
          enrollments={enrollments}
          onEdit={handleEditEnrollment}
          onDelete={handleDeleteEnrollment}
          showActions={true}
          viewMode={activeTab}
        />
      </div>
    </div>
  );
};

export default StudentCourseManagement;
