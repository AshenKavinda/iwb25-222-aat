import React from 'react';
import PropTypes from 'prop-types';

const TestList = ({ tests, subjects, onEdit, onDelete, onRestore, showActions, isDeleted }) => {
  const getTestTypeLabel = (type) => {
    switch (type) {
      case 'tm1': return 'Term 1';
      case 'tm2': return 'Term 2';
      case 'tm3': return 'Term 3';
      default: return type?.toUpperCase() || 'Unknown';
    }
  };

  const getTestTypeBadge = (type) => {
    const baseClass = 'test-type-badge';
    switch (type) {
      case 'tm1': return `${baseClass} tm1`;
      case 'tm2': return `${baseClass} tm2`;
      case 'tm3': return `${baseClass} tm3`;
      default: return `${baseClass} default`;
    }
  };

  const getSubjectName = (subjectId) => {
    const subject = subjects.find(s => s.subject_id === subjectId);
    return subject ? subject.name : 'Unknown Subject';
  };

  const formatDate = (dateString) => {
    if (!dateString) return 'N/A';
    try {
      return new Date(dateString).toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      });
    } catch {
      return 'Invalid Date';
    }
  };

  if (!tests || tests.length === 0) {
    return (
      <div className="empty-state">
        <div className="empty-icon">📝</div>
        <h3>{isDeleted ? 'No deleted tests found' : 'No tests found'}</h3>
        <p>{isDeleted ? 'All tests are currently active.' : 'Start by adding your first test.'}</p>
      </div>
    );
  }

  return (
    <div className="test-list">
      <div className="table-container">
        <table className="test-table">
          <thead>
            <tr>
              <th>Test ID</th>
              <th>Test Name</th>
              <th>Type</th>
              <th>Year</th>
              <th>Subject</th>
              <th>Created</th>
              {isDeleted && <th>Deleted</th>}
              {showActions && <th>Actions</th>}
            </tr>
          </thead>
          <tbody>
            {tests.map((test) => (
              <tr 
                key={test.test_id} 
                className={isDeleted ? 'deleted-row' : ''}
              >
                <td>
                  <span className="test-id">#{test.test_id}</span>
                </td>
                <td>
                  <div className="test-name">
                    <div className="name">{test.t_name}</div>
                  </div>
                </td>
                <td>
                  <span className={getTestTypeBadge(test.t_type)}>
                    {getTestTypeLabel(test.t_type)}
                  </span>
                </td>
                <td>
                  <span className="year">{test.year}</span>
                </td>
                <td>
                  <div className="subject-info">
                    <span className="subject-name">{getSubjectName(test.subject_id)}</span>
                    <span className="subject-id">ID: {test.subject_id}</span>
                  </div>
                </td>
                <td>
                  <span className="date">{formatDate(test.created_at)}</span>
                </td>
                {isDeleted && (
                  <td>
                    <span className="date deleted">{formatDate(test.deleted_at)}</span>
                  </td>
                )}
                {showActions && (
                  <td>
                    <div className="action-buttons">
                      {isDeleted ? (
                        onRestore && (
                          <button
                            onClick={() => onRestore(test.test_id)}
                            className="btn btn-success btn-sm"
                            title="Restore test"
                          >
                            Restore
                          </button>
                        )
                      ) : (
                        <>
                          {onEdit && (
                            <button
                              onClick={() => onEdit(test)}
                              className="btn btn-secondary btn-sm"
                              title="Edit test"
                            >
                              Edit
                            </button>
                          )}
                          {onDelete && (
                            <button
                              onClick={() => onDelete(test.test_id)}
                              className="btn btn-danger btn-sm"
                              title="Delete test"
                            >
                              Delete
                            </button>
                          )}
                        </>
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
        <p>
          {isDeleted 
            ? `${tests.length} deleted test${tests.length !== 1 ? 's' : ''} found`
            : `${tests.length} active test${tests.length !== 1 ? 's' : ''} found`
          }
        </p>
      </div>
    </div>
  );
};

TestList.propTypes = {
  tests: PropTypes.arrayOf(PropTypes.shape({
    test_id: PropTypes.number.isRequired,
    t_name: PropTypes.string.isRequired,
    t_type: PropTypes.string.isRequired,
    year: PropTypes.string.isRequired,
    subject_id: PropTypes.number.isRequired,
    created_at: PropTypes.string,
    deleted_at: PropTypes.string,
  })).isRequired,
  subjects: PropTypes.arrayOf(PropTypes.shape({
    subject_id: PropTypes.number.isRequired,
    name: PropTypes.string.isRequired,
  })).isRequired,
  onEdit: PropTypes.func,
  onDelete: PropTypes.func,
  onRestore: PropTypes.func,
  showActions: PropTypes.bool,
  isDeleted: PropTypes.bool,
};

TestList.defaultProps = {
  onEdit: null,
  onDelete: null,
  onRestore: null,
  showActions: false,
  isDeleted: false,
};

export default TestList;
