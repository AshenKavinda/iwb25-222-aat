import axios from 'axios';
import authService from './authService';

const API_BASE_URL = '/api';

// Create axios instance with default configuration
const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add request interceptor to include auth token
api.interceptors.request.use(
  (config) => {
    const token = authService.getAccessToken();
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Add response interceptor to handle errors
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401) {
      // Token expired, redirect to login
      authService.logout();
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

const studentCourseService = {
  // Add students to course (bulk enrollment)
  async addStudentsToCourse(courseId, studentIds, userId) {
    const response = await api.post('/student-course', {
      course_id: courseId,
      student_ids: studentIds,
      user_id: userId
    });
    return response.data;
  },

  // Update student course enrollment
  async updateStudentCourse(recordId, updateData) {
    const response = await api.put(`/student-course/${recordId}`, updateData);
    return response.data;
  },

  // Delete student course enrollment
  async deleteStudentCourse(recordId) {
    const response = await api.delete(`/student-course/${recordId}`);
    return response.data;
  },

  // Get student course enrollment by record ID
  async getStudentCourseById(recordId) {
    const response = await api.get(`/student-course/${recordId}`);
    return response.data;
  },

  // Get all enrollments for a specific student
  async getStudentCoursesByStudentId(studentId) {
    const response = await api.get(`/student-course/student/${studentId}`);
    return response.data;
  },

  // Get all students enrolled in a specific course
  async getStudentCoursesByCourseId(courseId) {
    const response = await api.get(`/student-course/course/${courseId}`);
    return response.data;
  },

  // Get student courses with details by student ID
  async getStudentCoursesWithDetailsByStudentId(studentId) {
    const response = await api.get(`/student-course/student/${studentId}/details`);
    return response.data;
  },

  // Get student courses with details by course ID
  async getStudentCoursesWithDetailsByCourseId(courseId) {
    const response = await api.get(`/student-course/course/${courseId}/details`);
    return response.data;
  },
};

export default studentCourseService;
