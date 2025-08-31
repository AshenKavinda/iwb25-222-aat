import React from 'react';
import PropTypes from 'prop-types';

const SubjectList = ({ subjects, onEdit, onDelete, onRestore, showActions, isDeleted }) => {
  const formatDate = (dateString) => {
    if (!dateString) return 'N/A';
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });
  };

  const formatWeight = (weight) => {
    if (weight === null || weight === undefined) return 'N/A';
    return parseFloat(weight).toFixed(2);
  };

  if (subjects.length === 0) {
    return (
      <div className="empty-state">
        <div className="empty-icon">📚</div>
        <h3>No subjects found</h3>
        <p>{isDeleted ? 'No deleted subjects to show.' : 'No subjects have been added yet.'}</p>
      </div>
    );
  }

  return (
    <div className="subject-list">
      <div className="table-container">
        <table className="subject-table">
          <thead>
            <tr>
              <th>Subject ID</th>
              <th>Subject Name</th>
              <th>Weight</th>
              <th>Created Date</th>
              <th>Updated Date</th>
              {isDeleted && <th>Deleted Date</th>}
              {showActions && <th>Actions</th>}
            </tr>
          </thead>
          <tbody>
            {subjects.map((subject) => (
              <tr key={subject.subject_id} className={isDeleted ? 'deleted-row' : ''}>
                <td>
                  <span className="subject-id">#{subject.subject_id}</span>
                </td>
                <td>
                  <div className="subject-name">
                    <span className="name">{subject.name}</span>
                  </div>
                </td>
                <td>
                  <span className="weight">{formatWeight(subject.weight)}</span>
                </td>
                <td>
                  <span className="date">{formatDate(subject.created_at)}</span>
                </td>
                <td>
                  <span className="date">{formatDate(subject.updated_at)}</span>
                </td>
                {isDeleted && (
                  <td>
                    <span className="date deleted">{formatDate(subject.deleted_at)}</span>
                  </td>
                )}
                {showActions && (
                  <td>
                    <div className="action-buttons">
                      {!isDeleted ? (
                        <>
                          <button
                            onClick={() => onEdit(subject)}
                            className="btn btn-sm btn-secondary"
                            title="Edit subject"
                          >
                            ✏️ Edit
                          </button>
                          <button
                            onClick={() => onDelete(subject.subject_id)}
                            className="btn btn-sm btn-danger"
                            title="Delete subject"
                          >
                            🗑️ Delete
                          </button>
                        </>
                      ) : (
                        <button
                          onClick={() => onRestore(subject.subject_id)}
                          className="btn btn-sm btn-success"
                          title="Restore subject"
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
        <p>Showing {subjects.length} {isDeleted ? 'deleted' : 'active'} subject{subjects.length !== 1 ? 's' : ''}</p>
      </div>
    </div>
  );
};

SubjectList.propTypes = {
  subjects: PropTypes.arrayOf(
    PropTypes.shape({
      subject_id: PropTypes.number.isRequired,
      name: PropTypes.string.isRequired,
      weight: PropTypes.oneOfType([PropTypes.number, PropTypes.string]).isRequired,
      created_at: PropTypes.string,
      updated_at: PropTypes.string,
      deleted_at: PropTypes.string,
    })
  ).isRequired,
  onEdit: PropTypes.func,
  onDelete: PropTypes.func,
  onRestore: PropTypes.func,
  showActions: PropTypes.bool,
  isDeleted: PropTypes.bool,
};

SubjectList.defaultProps = {
  onEdit: () => {},
  onDelete: () => {},
  onRestore: () => {},
  showActions: false,
  isDeleted: false,
};

export default SubjectList;
