import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';

const TestForm = ({ test, subjects, onSubmit, onCancel }) => {
  const [formData, setFormData] = useState({
    t_name: '',
    t_type: '',
    year: '',
    subject_id: '',
  });
  const [errors, setErrors] = useState({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    if (test) {
      setFormData({
        t_name: test.t_name || '',
        t_type: test.t_type || '',
        year: test.year || '',
        subject_id: test.subject_id || '',
      });
    } else {
      setFormData({
        t_name: '',
        t_type: '',
        year: new Date().getFullYear().toString(), // Default to current year
        subject_id: '',
      });
    }
  }, [test]);

  const validateForm = () => {
    const newErrors = {};

    // Validate test name
    if (!formData.t_name.trim()) {
      newErrors.t_name = 'Test name is required';
    } else if (formData.t_name.trim().length < 3) {
      newErrors.t_name = 'Test name must be at least 3 characters long';
    } else if (formData.t_name.trim().length > 100) {
      newErrors.t_name = 'Test name cannot exceed 100 characters';
    }

    // Validate test type
    if (!formData.t_type) {
      newErrors.t_type = 'Test type is required';
    } else if (!['tm1', 'tm2', 'tm3'].includes(formData.t_type)) {
      newErrors.t_type = 'Please select a valid test type';
    }

    // Validate year
    if (!formData.year) {
      newErrors.year = 'Year is required';
    } else {
      const yearNum = parseInt(formData.year);
      const currentYear = new Date().getFullYear();
      if (isNaN(yearNum) || yearNum < 2000 || yearNum > currentYear + 10) {
        newErrors.year = `Year must be between 2000 and ${currentYear + 10}`;
      }
    }

    // Validate subject
    if (!formData.subject_id) {
      newErrors.subject_id = 'Subject is required';
    } else {
      const subjectExists = subjects.some(s => s.subject_id === parseInt(formData.subject_id));
      if (!subjectExists) {
        newErrors.subject_id = 'Please select a valid subject';
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
      // Prepare data with proper types
      const submissionData = {
        t_name: formData.t_name.trim(),
        t_type: formData.t_type,
        year: formData.year,
        subject_id: parseInt(formData.subject_id),
      };

      await onSubmit(submissionData);
    } catch (error) {
      console.error('Form submission error:', error);
    } finally {
      setIsSubmitting(false);
    }
  };

  const getTestTypeLabel = (type) => {
    switch (type) {
      case 'tm1': return 'Term 1 (TM1)';
      case 'tm2': return 'Term 2 (TM2)';
      case 'tm3': return 'Term 3 (TM3)';
      default: return type;
    }
  };

  const getSubjectName = (subjectId) => {
    const subject = subjects.find(s => s.subject_id === parseInt(subjectId));
    return subject ? subject.name : 'Unknown Subject';
  };

  return (
    <form onSubmit={handleSubmit} className="test-form">
      <div className="form-group">
        <label htmlFor="t_name" className="form-label">
          Test Name <span className="required">*</span>
        </label>
        <input
          type="text"
          id="t_name"
          name="t_name"
          value={formData.t_name}
          onChange={handleInputChange}
          className={`form-input ${errors.t_name ? 'error' : ''}`}
          placeholder="Enter test name (e.g., Mathematics Term 1 Exam)"
          maxLength="100"
          disabled={isSubmitting}
        />
        {errors.t_name && <span className="error-message">{errors.t_name}</span>}
      </div>

      <div className="form-group">
        <label htmlFor="t_type" className="form-label">
          Test Type <span className="required">*</span>
        </label>
        <select
          id="t_type"
          name="t_type"
          value={formData.t_type}
          onChange={handleInputChange}
          className={`form-input form-select ${errors.t_type ? 'error' : ''}`}
          disabled={isSubmitting}
        >
          <option value="">Select test type</option>
          <option value="tm1">Term 1 (TM1)</option>
          <option value="tm2">Term 2 (TM2)</option>
          <option value="tm3">Term 3 (TM3)</option>
        </select>
        {errors.t_type && <span className="error-message">{errors.t_type}</span>}
      </div>

      <div className="form-group">
        <label htmlFor="year" className="form-label">
          Year <span className="required">*</span>
        </label>
        <input
          type="number"
          id="year"
          name="year"
          value={formData.year}
          onChange={handleInputChange}
          className={`form-input ${errors.year ? 'error' : ''}`}
          placeholder="Enter year (e.g., 2024)"
          min="2000"
          max={new Date().getFullYear() + 10}
          disabled={isSubmitting}
        />
        {errors.year && <span className="error-message">{errors.year}</span>}
      </div>

      <div className="form-group">
        <label htmlFor="subject_id" className="form-label">
          Subject <span className="required">*</span>
        </label>
        <select
          id="subject_id"
          name="subject_id"
          value={formData.subject_id}
          onChange={handleInputChange}
          className={`form-input form-select ${errors.subject_id ? 'error' : ''}`}
          disabled={isSubmitting}
        >
          <option value="">Select subject</option>
          {subjects.map(subject => (
            <option key={subject.subject_id} value={subject.subject_id}>
              {subject.name}
            </option>
          ))}
        </select>
        {errors.subject_id && <span className="error-message">{errors.subject_id}</span>}
      </div>

      {/* Preview section for editing */}
      {test && (
        <div className="form-preview">
          <h4>Current Test Information</h4>
          <div className="preview-grid">
            <div className="preview-item">
              <strong>Test Name:</strong> {test.t_name}
            </div>
            <div className="preview-item">
              <strong>Test Type:</strong> {getTestTypeLabel(test.t_type)}
            </div>
            <div className="preview-item">
              <strong>Year:</strong> {test.year}
            </div>
            <div className="preview-item">
              <strong>Subject:</strong> {getSubjectName(test.subject_id)}
            </div>
          </div>
        </div>
      )}

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
              {test ? 'Updating...' : 'Adding...'}
            </>
          ) : (
            test ? 'Update Test' : 'Add Test'
          )}
        </button>
      </div>
    </form>
  );
};

TestForm.propTypes = {
  test: PropTypes.shape({
    test_id: PropTypes.number,
    t_name: PropTypes.string,
    t_type: PropTypes.string,
    year: PropTypes.string,
    subject_id: PropTypes.number,
  }),
  subjects: PropTypes.arrayOf(PropTypes.shape({
    subject_id: PropTypes.number.isRequired,
    name: PropTypes.string.isRequired,
  })).isRequired,
  onSubmit: PropTypes.func.isRequired,
  onCancel: PropTypes.func.isRequired,
};

TestForm.defaultProps = {
  test: null,
};

export default TestForm;
