import React, { useState, useEffect } from 'react';
import './StudentCourseForm.css';

const StudentCourseForm = ({ 
  enrollment, 
  students, 
  courses, 
  selectedCourse, 
  onSubmit, 
  onCancel 
}) => {
  const [formData, setFormData] = useState({
    courseId: selectedCourse || '',
    studentIds: [],
    newCourseId: '',
    newStudentId: ''
  });
  const [selectedStudents, setSelectedStudents] = useState([]);
  const [availableStudents, setAvailableStudents] = useState([]);
  const [errors, setErrors] = useState({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    if (enrollment) {
      // Editing mode
      setFormData({
        courseId: enrollment.course_id,
        studentIds: [],
        newCourseId: enrollment.course_id,
        newStudentId: enrollment.student_id
      });
    } else if (selectedCourse) {
      // Pre-selected course for bulk enrollment
      setFormData(prev => ({
        ...prev,
        courseId: selectedCourse
      }));
    }
  }, [enrollment, selectedCourse]);

  useEffect(() => {
    // Filter out students that are already selected
    const available = students.filter(student => 
      !selectedStudents.some(selected => selected.student_id === student.student_id)
    );
    setAvailableStudents(available);
  }, [students, selectedStudents]);

  const handleCourseChange = (e) => {
    const courseId = e.target.value;
    setFormData(prev => ({
      ...prev,
      courseId,
      newCourseId: courseId
    }));
    setErrors(prev => ({ ...prev, courseId: '' }));
  };

  const handleStudentSelect = (studentId) => {
    const student = students.find(s => s.student_id.toString() === studentId);
    if (student && !selectedStudents.some(s => s.student_id === student.student_id)) {
      setSelectedStudents(prev => [...prev, student]);
      setErrors(prev => ({ ...prev, studentIds: '' }));
    }
  };

  const handleStudentRemove = (studentId) => {
    setSelectedStudents(prev => prev.filter(s => s.student_id !== studentId));
  };

  const handleNewStudentChange = (e) => {
    const studentId = e.target.value;
    setFormData(prev => ({
      ...prev,
      newStudentId: studentId
    }));
    setErrors(prev => ({ ...prev, newStudentId: '' }));
  };

  const validateForm = () => {
    const newErrors = {};

    if (enrollment) {
      // Edit mode validation
      if (!formData.newCourseId) {
        newErrors.newCourseId = 'Course is required';
      }
      if (!formData.newStudentId) {
        newErrors.newStudentId = 'Student is required';
      }
    } else {
      // Add mode validation
      if (!formData.courseId) {
        newErrors.courseId = 'Course is required';
      }
      if (selectedStudents.length === 0) {
        newErrors.studentIds = 'At least one student must be selected';
      }
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!validateForm()) {
      return;
    }

    setIsSubmitting(true);

    try {
      if (enrollment) {
        // Edit mode - update existing enrollment
        const updateData = {};
        if (formData.newCourseId !== enrollment.course_id) {
          updateData.course_id = parseInt(formData.newCourseId);
        }
        if (formData.newStudentId !== enrollment.student_id) {
          updateData.student_id = parseInt(formData.newStudentId);
        }
        
        if (Object.keys(updateData).length > 0) {
          await onSubmit(enrollment.record_id, updateData);
        }
      } else {
        // Add mode - enroll students in course
        const studentIds = selectedStudents.map(s => s.student_id);
        await onSubmit(parseInt(formData.courseId), studentIds);
      }
    } catch (error) {
      console.error('Form submission error:', error);
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleReset = () => {
    if (enrollment) {
      setFormData({
        courseId: enrollment.course_id,
        studentIds: [],
        newCourseId: enrollment.course_id,
        newStudentId: enrollment.student_id
      });
    } else {
      setFormData({
        courseId: selectedCourse || '',
        studentIds: [],
        newCourseId: '',
        newStudentId: ''
      });
      setSelectedStudents([]);
    }
    setErrors({});
  };

  return (
    <div className="student-course-form">
      <form onSubmit={handleSubmit} className="form">
        {enrollment ? (
          // Edit Mode
          <div className="form-section">
            <h4>Edit Enrollment</h4>
            <div className="current-enrollment">
              <p><strong>Current:</strong> {enrollment.student_name} enrolled in {enrollment.course_name}</p>
            </div>
            
            <div className="form-group">
              <label htmlFor="newCourseId" className="form-label">
                New Course <span className="required">*</span>
              </label>
              <select
                id="newCourseId"
                value={formData.newCourseId}
                onChange={(e) => setFormData(prev => ({ ...prev, newCourseId: e.target.value }))}
                className={`form-select ${errors.newCourseId ? 'error' : ''}`}
                disabled={isSubmitting}
              >
                <option value="">Select a course</option>
                {courses.map(course => (
                  <option key={course.course_id} value={course.course_id}>
                    {course.name} ({course.year})
                  </option>
                ))}
              </select>
              {errors.newCourseId && <span className="error-message">{errors.newCourseId}</span>}
            </div>

            <div className="form-group">
              <label htmlFor="newStudentId" className="form-label">
                New Student <span className="required">*</span>
              </label>
              <select
                id="newStudentId"
                value={formData.newStudentId}
                onChange={handleNewStudentChange}
                className={`form-select ${errors.newStudentId ? 'error' : ''}`}
                disabled={isSubmitting}
              >
                <option value="">Select a student</option>
                {students.map(student => (
                  <option key={student.student_id} value={student.student_id}>
                    {student.full_name}
                  </option>
                ))}
              </select>
              {errors.newStudentId && <span className="error-message">{errors.newStudentId}</span>}
            </div>
          </div>
        ) : (
          // Add Mode
          <div className="form-section">
            <h4>Enroll Students in Course</h4>
            
            <div className="form-group">
              <label htmlFor="courseId" className="form-label">
                Course <span className="required">*</span>
              </label>
              <select
                id="courseId"
                value={formData.courseId}
                onChange={handleCourseChange}
                className={`form-select ${errors.courseId ? 'error' : ''}`}
                disabled={isSubmitting || selectedCourse}
              >
                <option value="">Select a course</option>
                {courses.map(course => (
                  <option key={course.course_id} value={course.course_id}>
                    {course.name} ({course.year})
                    {course.hall && ` - ${course.hall}`}
                  </option>
                ))}
              </select>
              {errors.courseId && <span className="error-message">{errors.courseId}</span>}
            </div>

            <div className="form-group">
              <label htmlFor="studentSelect" className="form-label">
                Add Students <span className="required">*</span>
              </label>
              <select
                id="studentSelect"
                onChange={(e) => {
                  if (e.target.value) {
                    handleStudentSelect(e.target.value);
                    e.target.value = '';
                  }
                }}
                className="form-select"
                disabled={isSubmitting}
              >
                <option value="">Select students to add...</option>
                {availableStudents.map(student => (
                  <option key={student.student_id} value={student.student_id}>
                    {student.full_name} (ID: {student.student_id})
                  </option>
                ))}
              </select>
              {errors.studentIds && <span className="error-message">{errors.studentIds}</span>}
            </div>

            {selectedStudents.length > 0 && (
              <div className="selected-students">
                <h5>Selected Students ({selectedStudents.length})</h5>
                <div className="student-chips">
                  {selectedStudents.map(student => (
                    <div key={student.student_id} className="student-chip">
                      <span className="student-name">{student.full_name}</span>
                      <button
                        type="button"
                        onClick={() => handleStudentRemove(student.student_id)}
                        className="remove-btn"
                        disabled={isSubmitting}
                      >
                        ×
                      </button>
                    </div>
                  ))}
                </div>
              </div>
            )}
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
            type="button"
            onClick={handleReset}
            className="btn btn-secondary"
            disabled={isSubmitting}
          >
            Reset
          </button>
          <button
            type="submit"
            className="btn btn-primary"
            disabled={isSubmitting}
          >
            {isSubmitting ? 'Processing...' : (enrollment ? 'Update Enrollment' : 'Enroll Students')}
          </button>
        </div>
      </form>
    </div>
  );
};

export default StudentCourseForm;
