import React, { useState, useEffect } from 'react';
import { useAuth } from '../../hooks/useAuth';
import './CourseForm.css';

const CourseForm = ({ course, onSubmit, onCancel }) => {
  const { user } = useAuth();
  const [formData, setFormData] = useState({
    name: '',
    hall: '',
    year: ''
  });
  const [errors, setErrors] = useState({});
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (course) {
      setFormData({
        name: course.name || '',
        hall: course.hall || '',
        year: course.year || ''
      });
    }
  }, [course]);

  const validateForm = () => {
    const newErrors = {};

    if (!formData.name.trim()) {
      newErrors.name = 'Course name is required';
    } else if (formData.name.length < 2) {
      newErrors.name = 'Course name must be at least 2 characters';
    }

    if (!formData.year.trim()) {
      newErrors.year = 'Year is required';
    } else if (!/^\d{4}$/.test(formData.year)) {
      newErrors.year = 'Year must be a 4-digit number';
    }

    // Hall is optional, so no validation needed

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
    
    // Clear error when user starts typing
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

    setLoading(true);
    try {
      // Prepare data for submission
      const submissionData = {
        name: formData.name.trim(),
        year: formData.year.trim()
      };

      // Only include hall if it's not empty
      if (formData.hall.trim()) {
        submissionData.hall = formData.hall.trim();
      }

      // Add user_id for new courses
      if (!course) {
        submissionData.user_id = user.user_id;
      }

      await onSubmit(submissionData);
      
      // Reset form if it's a new course
      if (!course) {
        setFormData({
          name: '',
          hall: '',
          year: ''
        });
        setErrors({});
      }
    } catch (error) {
      console.error('Form submission error:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="course-form">
      <form onSubmit={handleSubmit}>
        <div className="form-row">
          <div className="form-group">
            <label htmlFor="name" className="form-label">
              Course Name <span className="required">*</span>
            </label>
            <input
              type="text"
              id="name"
              name="name"
              value={formData.name}
              onChange={handleChange}
              className={`form-input ${errors.name ? 'error' : ''}`}
              placeholder="Enter course name"
              maxLength="100"
            />
            {errors.name && <span className="error-message">{errors.name}</span>}
          </div>

          <div className="form-group">
            <label htmlFor="year" className="form-label">
              Year <span className="required">*</span>
            </label>
            <input
              type="text"
              id="year"
              name="year"
              value={formData.year}
              onChange={handleChange}
              className={`form-input ${errors.year ? 'error' : ''}`}
              placeholder="e.g., 2024"
              maxLength="4"
            />
            {errors.year && <span className="error-message">{errors.year}</span>}
          </div>
        </div>

        <div className="form-group">
          <label htmlFor="hall" className="form-label">
            Hall (Optional)
          </label>
          <input
            type="text"
            id="hall"
            name="hall"
            value={formData.hall}
            onChange={handleChange}
            className="form-input"
            placeholder="Enter hall name"
            maxLength="50"
          />
        </div>

        <div className="form-actions">
          <button
            type="submit"
            disabled={loading}
            className="btn btn-primary"
          >
            {loading && <span className="spinner"></span>}
            {course ? 'Update Course' : 'Add Course'}
          </button>
          <button
            type="button"
            onClick={onCancel}
            disabled={loading}
            className="btn btn-secondary"
          >
            Cancel
          </button>
        </div>
      </form>
    </div>
  );
};

export default CourseForm;
