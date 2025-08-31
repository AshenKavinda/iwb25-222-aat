import React from 'react';
import PropTypes from 'prop-types';

const StudentList = ({ students, onEdit, onDelete, onRestore, showActions, isDeleted }) => {
  const formatDate = (dateString) => {
    if (!dateString) return 'N/A';
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });
  };

  const calculateAge = (dobString) => {
    if (!dobString) return 'N/A';
    const birthDate = new Date(dobString);
    const today = new Date();
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();
    
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }
    
    return age;
  };

  if (students.length === 0) {
    return (
      <div className="empty-state">
        <div className="empty-icon">👨‍🎓</div>
        <h3>No students found</h3>
        <p>{isDeleted ? 'No deleted students to show.' : 'No students have been added yet.'}</p>
      </div>
    );
  }

  return (
    <div className="student-list">
      <div className="table-container">
        <table className="student-table">
          <thead>
            <tr>
              <th>Student ID</th>
              <th>Full Name</th>
              <th>Parent NIC</th>
              <th>Date of Birth</th>
              <th>Age</th>
              <th>Created Date</th>
              {isDeleted && <th>Deleted Date</th>}
              {showActions && <th>Actions</th>}
            </tr>
          </thead>
          <tbody>
            {students.map((student) => (
              <tr key={student.student_id} className={isDeleted ? 'deleted-row' : ''}>
                <td>
                  <span className="student-id">#{student.student_id}</span>
                </td>
                <td>
                  <div className="student-name">
                    <span className="name">{student.full_name}</span>
                  </div>
                </td>
                <td>
                  <span className="nic">{student.parent_nic}</span>
                </td>
                <td>
                  <span className="date">{formatDate(student.dob)}</span>
                </td>
                <td>
                  <span className="age">{calculateAge(student.dob)} years</span>
                </td>
                <td>
                  <span className="date">{formatDate(student.created_at)}</span>
                </td>
                {isDeleted && (
                  <td>
                    <span className="date deleted">{formatDate(student.deleted_at)}</span>
                  </td>
                )}
                {showActions && (
                  <td>
                    <div className="action-buttons">
                      {!isDeleted ? (
                        <>
                          <button
                            onClick={() => onEdit(student)}
                            className="btn btn-sm btn-secondary"
                            title="Edit student"
                          >
                            ✏️ Edit
                          </button>
                          <button
                            onClick={() => onDelete(student.student_id)}
                            className="btn btn-sm btn-danger"
                            title="Delete student"
                          >
                            🗑️ Delete
                          </button>
                        </>
                      ) : (
                        <button
                          onClick={() => onRestore(student.student_id)}
                          className="btn btn-sm btn-success"
                          title="Restore student"
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
        <p>Showing {students.length} {isDeleted ? 'deleted' : 'active'} student{students.length !== 1 ? 's' : ''}</p>
      </div>
    </div>
  );
};

StudentList.propTypes = {
  students: PropTypes.arrayOf(
    PropTypes.shape({
      student_id: PropTypes.number.isRequired,
      full_name: PropTypes.string.isRequired,
      parent_nic: PropTypes.string.isRequired,
      dob: PropTypes.string.isRequired,
      created_at: PropTypes.string,
      deleted_at: PropTypes.string,
    })
  ).isRequired,
  onEdit: PropTypes.func,
  onDelete: PropTypes.func,
  onRestore: PropTypes.func,
  showActions: PropTypes.bool,
  isDeleted: PropTypes.bool,
};

StudentList.defaultProps = {
  onEdit: () => {},
  onDelete: () => {},
  onRestore: () => {},
  showActions: false,
  isDeleted: false,
};

export default StudentList;
