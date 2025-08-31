import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';

const StudentForm = ({ student, onSubmit, onCancel }) => {
  const [formData, setFormData] = useState({
    parent_nic: '',
    full_name: '',
    dob: '',
  });
  const [errors, setErrors] = useState({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    if (student) {
      setFormData({
        parent_nic: student.parent_nic || '',
        full_name: student.full_name || '',
        dob: student.dob ? student.dob.split('T')[0] : '', // Format date for input
      });
    } else {
      setFormData({
        parent_nic: '',
        full_name: '',
        dob: '',
      });
    }
  }, [student]);

  const validateForm = () => {
    const newErrors = {};

    // Validate parent NIC
    if (!formData.parent_nic.trim()) {
      newErrors.parent_nic = 'Parent NIC is required';
    } else if (!/^[0-9]{9}[vVxX]$|^[0-9]{12}$/.test(formData.parent_nic.trim())) {
      newErrors.parent_nic = 'Please enter a valid NIC number (9 digits + V/X or 12 digits)';
    }

    // Validate full name
    if (!formData.full_name.trim()) {
      newErrors.full_name = 'Full name is required';
    } else if (formData.full_name.trim().length < 2) {
      newErrors.full_name = 'Full name must be at least 2 characters long';
    } else if (!/^[a-zA-Z\s.'-]+$/.test(formData.full_name.trim())) {
      newErrors.full_name = 'Full name can only contain letters, spaces, periods, hyphens, and apostrophes';
    }

    // Validate date of birth
    if (!formData.dob) {
      newErrors.dob = 'Date of birth is required';
    } else {
      const birthDate = new Date(formData.dob);
      const today = new Date();
      let age = today.getFullYear() - birthDate.getFullYear();
      const monthDiff = today.getMonth() - birthDate.getMonth();
      
      if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
        age--;
      }

      if (birthDate > today) {
        newErrors.dob = 'Date of birth cannot be in the future';
      } else if (age < 3) {
        newErrors.dob = 'Student must be at least 3 years old';
      } else if (age > 25) {
        newErrors.dob = 'Student cannot be older than 25 years';
      }
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));

    // Clear specific field error when user starts typing
    if (errors[name]) {
      setErrors(prev => ({
        ...prev,
        [name]: ''
      }));
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!validateForm()) {
      return;
    }

    setIsSubmitting(true);
    try {
      // Trim whitespace from form data
      const trimmedData = {
        parent_nic: formData.parent_nic.trim(),
        full_name: formData.full_name.trim(),
        dob: formData.dob,
      };

      await onSubmit(trimmedData);
    } catch (error) {
      console.error('Form submission error:', error);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="student-form">
      <div className="form-group">
        <label htmlFor="parent_nic" className="form-label">
          Parent NIC <span className="required">*</span>
        </label>
        <input
          type="text"
          id="parent_nic"
          name="parent_nic"
          value={formData.parent_nic}
          onChange={handleInputChange}
          className={`form-input ${errors.parent_nic ? 'error' : ''}`}
          placeholder="Enter parent's NIC number"
          maxLength="12"
          disabled={isSubmitting}
        />
        {errors.parent_nic && <span className="error-message">{errors.parent_nic}</span>}
      </div>

      <div className="form-group">
        <label htmlFor="full_name" className="form-label">
          Full Name <span className="required">*</span>
        </label>
        <input
          type="text"
          id="full_name"
          name="full_name"
          value={formData.full_name}
          onChange={handleInputChange}
          className={`form-input ${errors.full_name ? 'error' : ''}`}
          placeholder="Enter student's full name"
          maxLength="100"
          disabled={isSubmitting}
        />
        {errors.full_name && <span className="error-message">{errors.full_name}</span>}
      </div>

      <div className="form-group">
        <label htmlFor="dob" className="form-label">
          Date of Birth <span className="required">*</span>
        </label>
        <input
          type="date"
          id="dob"
          name="dob"
          value={formData.dob}
          onChange={handleInputChange}
          className={`form-input ${errors.dob ? 'error' : ''}`}
          max={new Date().toISOString().split('T')[0]} // Prevent future dates
          disabled={isSubmitting}
        />
        {errors.dob && <span className="error-message">{errors.dob}</span>}
      </div>

      <div className="form-actions">
        <button
          type="button"
          onClick={onCancel}
          className="btn btn-secondary"
          disabled={isSubmitting}
        >
          Cancel
        </button>
        <button
          type="submit"
          className="btn btn-primary"
          disabled={isSubmitting}
        >
          {isSubmitting ? (
            <>
              <span className="spinner"></span>
              {student ? 'Updating...' : 'Adding...'}
            </>
          ) : (
            student ? 'Update Student' : 'Add Student'
          )}
        </button>
      </div>
    </form>
  );
};

StudentForm.propTypes = {
  student: PropTypes.shape({
    student_id: PropTypes.number,
    parent_nic: PropTypes.string,
    full_name: PropTypes.string,
    dob: PropTypes.string,
  }),
  onSubmit: PropTypes.func.isRequired,
  onCancel: PropTypes.func.isRequired,
};

StudentForm.defaultProps = {
  student: null,
};

export default StudentForm;
