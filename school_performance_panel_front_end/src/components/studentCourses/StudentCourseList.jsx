import React, { useState } from 'react';
import './StudentCourseList.css';

const StudentCourseList = ({ 
  enrollments, 
  onEdit, 
  onDelete, 
  showActions = true,
  viewMode = 'all'
}) => {
  const [sortConfig, setSortConfig] = useState({
    key: 'created_at',
    direction: 'desc'
  });
  const [currentPage, setCurrentPage] = useState(1);
  const [itemsPerPage] = useState(10);

  const handleSort = (key) => {
    let direction = 'asc';
    if (sortConfig.key === key && sortConfig.direction === 'asc') {
      direction = 'desc';
    }
    setSortConfig({ key, direction });
  };

  const sortedEnrollments = React.useMemo(() => {
    const sortableEnrollments = [...enrollments];
    if (sortConfig.key) {
      sortableEnrollments.sort((a, b) => {
        let aValue = a[sortConfig.key];
        let bValue = b[sortConfig.key];

        // Handle string sorting
        if (typeof aValue === 'string') {
          aValue = aValue.toLowerCase();
        }
        if (typeof bValue === 'string') {
          bValue = bValue.toLowerCase();
        }

        if (aValue < bValue) {
          return sortConfig.direction === 'asc' ? -1 : 1;
        }
        if (aValue > bValue) {
          return sortConfig.direction === 'asc' ? 1 : -1;
        }
        return 0;
      });
    }
    return sortableEnrollments;
  }, [enrollments, sortConfig]);

  // Pagination
  const totalPages = Math.ceil(sortedEnrollments.length / itemsPerPage);
  const startIndex = (currentPage - 1) * itemsPerPage;
  const endIndex = startIndex + itemsPerPage;
  const currentEnrollments = sortedEnrollments.slice(startIndex, endIndex);

  const handlePageChange = (page) => {
    setCurrentPage(page);
  };

  const formatDate = (dateString) => {
    try {
      return new Date(dateString).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      });
    } catch {
      return dateString;
    }
  };

  const getSortIcon = (columnKey) => {
    if (sortConfig.key === columnKey) {
      return sortConfig.direction === 'asc' ? '↑' : '↓';
    }
    return '↕';
  };

  if (enrollments.length === 0) {
    return (
      <div className="empty-state">
        <div className="empty-icon">📚</div>
        <h3>No enrollments found</h3>
        <p>
          {viewMode === 'by-student' ? 
            'This student is not enrolled in any courses.' :
            viewMode === 'by-course' ?
            'No students are enrolled in this course.' :
            'No student course enrollments exist yet.'
          }
        </p>
      </div>
    );
  }

  return (
    <div className="student-course-list">
      <div className="list-header">
        <div className="list-stats">
          <span className="total-count">
            Showing {startIndex + 1}-{Math.min(endIndex, sortedEnrollments.length)} of {sortedEnrollments.length} enrollment{sortedEnrollments.length !== 1 ? 's' : ''}
          </span>
        </div>
      </div>

      <div className="table-container">
        <table className="enrollments-table">
          <thead>
            <tr>
              <th 
                className="sortable"
                onClick={() => handleSort('record_id')}
              >
                Record ID {getSortIcon('record_id')}
              </th>
              {viewMode !== 'by-student' && (
                <th 
                  className="sortable"
                  onClick={() => handleSort('student_name')}
                >
                  Student {getSortIcon('student_name')}
                </th>
              )}
              {viewMode !== 'by-course' && (
                <th 
                  className="sortable"
                  onClick={() => handleSort('course_name')}
                >
                  Course {getSortIcon('course_name')}
                </th>
              )}
              <th 
                className="sortable"
                onClick={() => handleSort('course_year')}
              >
                Year {getSortIcon('course_year')}
              </th>
              <th 
                className="sortable"
                onClick={() => handleSort('created_at')}
              >
                Enrolled Date {getSortIcon('created_at')}
              </th>
              <th 
                className="sortable"
                onClick={() => handleSort('updated_at')}
              >
                Last Updated {getSortIcon('updated_at')}
              </th>
              {showActions && (
                <th className="actions-column">Actions</th>
              )}
            </tr>
          </thead>
          <tbody>
            {currentEnrollments.map((enrollment) => (
              <tr key={enrollment.record_id} className="enrollment-row">
                <td className="record-id">{enrollment.record_id}</td>
                {viewMode !== 'by-student' && (
                  <td className="student-info">
                    <div className="student-details">
                      <div className="student-name">{enrollment.student_name}</div>
                      <div className="student-id">ID: {enrollment.student_id}</div>
                    </div>
                  </td>
                )}
                {viewMode !== 'by-course' && (
                  <td className="course-info">
                    <div className="course-details">
                      <div className="course-name">{enrollment.course_name}</div>
                      <div className="course-id">ID: {enrollment.course_id}</div>
                    </div>
                  </td>
                )}
                <td className="course-year">
                  <span className="year-badge">{enrollment.course_year}</span>
                </td>
                <td className="date-info">
                  {formatDate(enrollment.created_at)}
                </td>
                <td className="date-info">
                  {formatDate(enrollment.updated_at)}
                </td>
                {showActions && (
                  <td className="actions">
                    <div className="action-buttons">
                      <button
                        onClick={() => onEdit(enrollment)}
                        className="btn btn-sm btn-secondary"
                        title="Edit enrollment"
                      >
                        Edit
                      </button>
                      <button
                        onClick={() => onDelete(enrollment.record_id)}
                        className="btn btn-sm btn-danger"
                        title="Remove from course"
                      >
                        Remove
                      </button>
                    </div>
                  </td>
                )}
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="pagination">
          <div className="pagination-info">
            Page {currentPage} of {totalPages}
          </div>
          <div className="pagination-controls">
            <button
              onClick={() => handlePageChange(currentPage - 1)}
              disabled={currentPage === 1}
              className="pagination-btn"
            >
              Previous
            </button>
            
            {[...Array(totalPages)].map((_, index) => {
              const page = index + 1;
              const showPage = 
                page === 1 || 
                page === totalPages || 
                (page >= currentPage - 2 && page <= currentPage + 2);
              
              if (!showPage) {
                if (page === currentPage - 3 || page === currentPage + 3) {
                  return <span key={page} className="pagination-ellipsis">...</span>;
                }
                return null;
              }
              
              return (
                <button
                  key={page}
                  onClick={() => handlePageChange(page)}
                  className={`pagination-btn ${currentPage === page ? 'active' : ''}`}
                >
                  {page}
                </button>
              );
            })}
            
            <button
              onClick={() => handlePageChange(currentPage + 1)}
              disabled={currentPage === totalPages}
              className="pagination-btn"
            >
              Next
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

export default StudentCourseList;
