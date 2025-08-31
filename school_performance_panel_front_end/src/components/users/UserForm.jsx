import React, { useState, useEffect } from 'react';

const UserForm = ({ user, onSubmit, onCancel }) => {
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    role: 'guest',
    name: '',
    phone_number: '',
    dob: ''
  });
  
  const [errors, setErrors] = useState({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    if (user) {
      setFormData({
        email: user.user?.email || '',
        password: '', // Don't show password for editing
        role: user.user?.role || 'guest',
        name: user.profile?.name || '',
        phone_number: user.profile?.phone_number || '',
        dob: user.profile?.dob || ''
      });
    }
  }, [user]);

  const validateForm = () => {
    const newErrors = {};

    // Email validation
    if (!formData.email.trim()) {
      newErrors.email = 'Email is required';
    } else if (!/\S+@\S+\.\S+/.test(formData.email)) {
      newErrors.email = 'Email format is invalid';
    }

    // Password validation (only for new users)
    if (!user && !formData.password.trim()) {
      newErrors.password = 'Password is required for new users';
    } else if (!user && formData.password.length < 6) {
      newErrors.password = 'Password must be at least 6 characters';
    }

    // Name validation
    if (!formData.name.trim()) {
      newErrors.name = 'Name is required';
    }

    // Role validation
    if (!formData.role) {
      newErrors.role = 'Role is required';
    }

    // Phone number validation (optional but format check if provided)
    if (formData.phone_number && !/^\+?\d{10,15}$/.test(formData.phone_number.replace(/\s/g, ''))) {
      newErrors.phone_number = 'Invalid phone number format';
    }

    // Date of birth validation (optional but format check if provided)
    if (formData.dob) {
      const dobDate = new Date(formData.dob);
      const today = new Date();
      if (dobDate >= today) {
        newErrors.dob = 'Date of birth must be in the past';
      }
    }

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

    setIsSubmitting(true);
    
    try {
      // Prepare data for submission
      const submitData = { ...formData };
      
      // For editing users, remove password if it's empty
      if (user && !submitData.password.trim()) {
        delete submitData.password;
      }
      
      // Remove empty optional fields
      if (!submitData.phone_number.trim()) {
        delete submitData.phone_number;
      }
      if (!submitData.dob) {
        delete submitData.dob;
      }

      await onSubmit(submitData);
    } catch (error) {
      console.error('Form submission error:', error);
    } finally {
      setIsSubmitting(false);
    }
  };

  const userRoles = [
    { value: 'manager', label: 'Manager' },
    { value: 'teacher', label: 'Teacher' },
    { value: 'officer', label: 'Officer' },
    { value: 'guest', label: 'Guest' }
  ];

  return (
    <form onSubmit={handleSubmit} className="user-form">
      <div className="form-group">
        <label htmlFor="email" className="form-label">
          Email <span className="required">*</span>
        </label>
        <input
          type="email"
          id="email"
          name="email"
          value={formData.email}
          onChange={handleChange}
          className={`form-input ${errors.email ? 'error' : ''}`}
          placeholder="Enter email address"
          disabled={user} // Email cannot be changed for existing users
        />
        {errors.email && <span className="error-message">{errors.email}</span>}
      </div>

      {!user && (
        <div className="form-group">
          <label htmlFor="password" className="form-label">
            Password <span className="required">*</span>
          </label>
          <input
            type="password"
            id="password"
            name="password"
            value={formData.password}
            onChange={handleChange}
            className={`form-input ${errors.password ? 'error' : ''}`}
            placeholder="Enter password (min 6 characters)"
          />
          {errors.password && <span className="error-message">{errors.password}</span>}
        </div>
      )}

      <div className="form-group">
        <label htmlFor="role" className="form-label">
          Role <span className="required">*</span>
        </label>
        <select
          id="role"
          name="role"
          value={formData.role}
          onChange={handleChange}
          className={`form-input ${errors.role ? 'error' : ''}`}
        >
          {userRoles.map(role => (
            <option key={role.value} value={role.value}>
              {role.label}
            </option>
          ))}
        </select>
        {errors.role && <span className="error-message">{errors.role}</span>}
      </div>

      <div className="form-group">
        <label htmlFor="name" className="form-label">
          Full Name <span className="required">*</span>
        </label>
        <input
          type="text"
          id="name"
          name="name"
          value={formData.name}
          onChange={handleChange}
          className={`form-input ${errors.name ? 'error' : ''}`}
          placeholder="Enter full name"
        />
        {errors.name && <span className="error-message">{errors.name}</span>}
      </div>

      <div className="form-group">
        <label htmlFor="phone_number" className="form-label">
          Phone Number
        </label>
        <input
          type="tel"
          id="phone_number"
          name="phone_number"
          value={formData.phone_number}
          onChange={handleChange}
          className={`form-input ${errors.phone_number ? 'error' : ''}`}
          placeholder="Enter phone number (optional)"
        />
        {errors.phone_number && <span className="error-message">{errors.phone_number}</span>}
      </div>

      <div className="form-group">
        <label htmlFor="dob" className="form-label">
          Date of Birth
        </label>
        <input
          type="date"
          id="dob"
          name="dob"
          value={formData.dob}
          onChange={handleChange}
          className={`form-input ${errors.dob ? 'error' : ''}`}
          max={new Date().toISOString().split('T')[0]}
        />
        {errors.dob && <span className="error-message">{errors.dob}</span>}
      </div>

      <div className="form-actions">
        <button
          type="submit"
          className="btn btn-primary"
          disabled={isSubmitting}
        >
          {isSubmitting && <span className="spinner"></span>}
          {user ? 'Update User' : 'Add User'}
        </button>
        <button
          type="button"
          onClick={onCancel}
          className="btn btn-secondary"
          disabled={isSubmitting}
        >
          Cancel
        </button>
      </div>
    </form>
  );
};

export default UserForm;
