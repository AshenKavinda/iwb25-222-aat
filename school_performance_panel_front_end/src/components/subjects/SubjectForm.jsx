import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';

const SubjectForm = ({ subject, onSubmit, onCancel }) => {
  const [formData, setFormData] = useState({
    name: '',
    weight: '',
  });
  const [errors, setErrors] = useState({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    if (subject) {
      setFormData({
        name: subject.name || '',
        weight: subject.weight ? subject.weight.toString() : '',
      });
    } else {
      setFormData({
        name: '',
        weight: '',
      });
    }
  }, [subject]);

  const validateForm = () => {
    const newErrors = {};

    // Validate subject name
    if (!formData.name.trim()) {
      newErrors.name = 'Subject name is required';
    } else if (formData.name.trim().length < 2) {
      newErrors.name = 'Subject name must be at least 2 characters long';
    } else if (formData.name.trim().length > 100) {
      newErrors.name = 'Subject name cannot exceed 100 characters';
    } else if (!/^[a-zA-Z0-9\s.&'-]+$/.test(formData.name.trim())) {
      newErrors.name = 'Subject name can only contain letters, numbers, spaces, periods, ampersands, hyphens, and apostrophes';
    }

    // Validate weight
    if (!formData.weight.trim()) {
      newErrors.weight = 'Subject weight is required';
    } else {
      const weight = parseFloat(formData.weight.trim());
      if (isNaN(weight)) {
        newErrors.weight = 'Weight must be a valid number';
      } else if (weight <= 0) {
        newErrors.weight = 'Weight must be greater than 0';
      } else if (weight > 100) {
        newErrors.weight = 'Weight cannot exceed 100';
      } else if (weight.toString().split('.')[1]?.length > 2) {
        newErrors.weight = 'Weight can have at most 2 decimal places';
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
      // Trim whitespace and convert weight to number
      const trimmedData = {
        name: formData.name.trim(),
        weight: parseFloat(formData.weight.trim()),
      };

      await onSubmit(trimmedData);
    } catch (error) {
      console.error('Form submission error:', error);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="subject-form">
      <div className="form-group">
        <label htmlFor="name" className="form-label">
          Subject Name <span className="required">*</span>
        </label>
        <input
          type="text"
          id="name"
          name="name"
          value={formData.name}
          onChange={handleInputChange}
          className={`form-input ${errors.name ? 'error' : ''}`}
          placeholder="Enter subject name (e.g., Mathematics, Science, English)"
          maxLength="100"
          disabled={isSubmitting}
        />
        {errors.name && <span className="error-message">{errors.name}</span>}
      </div>

      <div className="form-group">
        <label htmlFor="weight" className="form-label">
          Subject Weight <span className="required">*</span>
        </label>
        <input
          type="number"
          id="weight"
          name="weight"
          value={formData.weight}
          onChange={handleInputChange}
          className={`form-input ${errors.weight ? 'error' : ''}`}
          placeholder="Enter weight (e.g., 10.5, 15, 20)"
          min="0.01"
          max="100"
          step="0.01"
          disabled={isSubmitting}
        />
        {errors.weight && <span className="error-message">{errors.weight}</span>}
        <small className="form-help">
          Weight represents the importance or credit value of this subject in calculations
        </small>
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
              {subject ? 'Updating...' : 'Adding...'}
            </>
          ) : (
            <>
              {subject ? 'Update Subject' : 'Add Subject'}
            </>
          )}
        </button>
      </div>
    </form>
  );
};

SubjectForm.propTypes = {
  subject: PropTypes.shape({
    subject_id: PropTypes.number,
    name: PropTypes.string,
    weight: PropTypes.oneOfType([PropTypes.number, PropTypes.string]),
  }),
  onSubmit: PropTypes.func.isRequired,
  onCancel: PropTypes.func.isRequired,
};

SubjectForm.defaultProps = {
  subject: null,
};

export default SubjectForm;
