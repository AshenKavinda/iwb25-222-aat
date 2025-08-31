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

const studentService = {
  // Get all students
  async getAllStudents() {
    const response = await api.get('/student');
    return response.data;
  },

  // Get student by ID
  async getStudentById(studentId) {
    const response = await api.get(`/student/${studentId}`);
    return response.data;
  },

  // Add new student
  async addStudent(studentData) {
    const response = await api.post('/student', studentData);
    return response.data;
  },

  // Update student
  async updateStudent(studentId, studentData) {
    const response = await api.put(`/student/${studentId}`, studentData);
    return response.data;
  },

  // Soft delete student
  async deleteStudent(studentId) {
    const response = await api.delete(`/student/${studentId}`);
    return response.data;
  },

  // Restore deleted student
  async restoreStudent(studentId) {
    const response = await api.post(`/student/${studentId}/restore`);
    return response.data;
  },

  // Get all deleted students
  async getDeletedStudents() {
    const response = await api.get('/student/deleted');
    return response.data;
  },

  // Search students by name
  async searchStudentsByName(name) {
    const response = await api.get(`/student/search?name=${encodeURIComponent(name)}`);
    return response.data;
  },
};

export default studentService;
