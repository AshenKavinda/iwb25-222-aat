import React from 'react';
import './CourseList.css';

const CourseList = ({ courses, onEdit, onDelete, onRestore, showActions = true, isDeleted = false }) => {
  if (!courses || courses.length === 0) {
    return (
      <div className="empty-state">
        <div className="empty-icon">📚</div>
        <h3>No courses found</h3>
        <p>{isDeleted ? 'No deleted courses to display' : 'No courses available'}</p>
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

  return (
    <div className="course-list">
      <div className="table-container">
        <table className="course-table">
          <thead>
            <tr>
              <th>Course ID</th>
              <th>Course Name</th>
              <th>Hall</th>
              <th>Year</th>
              <th>Created</th>
              {isDeleted && <th>Deleted</th>}
              {showActions && <th>Actions</th>}
            </tr>
          </thead>
          <tbody>
            {courses.map((course, index) => (
              <tr key={course.course_id || index} className={isDeleted ? 'deleted-row' : ''}>
                <td>
                  <span className="course-id">#{course.course_id}</span>
                </td>
                <td>
                  <div className="course-name">
                    <span className="name">{course.name}</span>
                  </div>
                </td>
                <td>
                  <span className="hall">{course.hall || 'Not specified'}</span>
                </td>
                <td>
                  <span className="year-badge">{course.year}</span>
                </td>
                <td>
                  <span className="date">{formatDate(course.created_at)}</span>
                </td>
                {isDeleted && (
                  <td>
                    <span className="date deleted">{formatDate(course.deleted_at)}</span>
                  </td>
                )}
                {showActions && (
                  <td>
                    <div className="action-buttons">
                      {!isDeleted ? (
                        <>
                          <button
                            onClick={() => onEdit && onEdit(course)}
                            className="btn btn-sm btn-secondary"
                            title="Edit course"
                          >
                            ✏️ Edit
                          </button>
                          <button
                            onClick={() => onDelete && onDelete(course.course_id)}
                            className="btn btn-sm btn-danger"
                            title="Delete course"
                          >
                            🗑️ Delete
                          </button>
                        </>
                      ) : (
                        <button
                          onClick={() => onRestore && onRestore(course.course_id)}
                          className="btn btn-sm btn-success"
                          title="Restore course"
                        >
                          ↩️ Restore
                        </button>
                      )}
                    </div>
                  </td>
                )}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <div className="table-footer">
        <p>{courses.length} course{courses.length !== 1 ? 's' : ''} found</p>
      </div>
    </div>
  );
};

export default CourseList;
