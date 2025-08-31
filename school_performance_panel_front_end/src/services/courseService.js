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

const courseService = {
  // Get all courses
  async getAllCourses() {
    const response = await api.get('/course');
    return response.data;
  },

  // Get course by ID
  async getCourseById(courseId) {
    const response = await api.get(`/course/${courseId}`);
    return response.data;
  },

  // Add new course
  async addCourse(courseData) {
    const response = await api.post('/course', courseData);
    return response.data;
  },

  // Update course
  async updateCourse(courseId, courseData) {
    const response = await api.put(`/course/${courseId}`, courseData);
    return response.data;
  },

  // Soft delete course
  async deleteCourse(courseId) {
    const response = await api.delete(`/course/${courseId}`);
    return response.data;
  },

  // Restore deleted course
  async restoreCourse(courseId) {
    const response = await api.post(`/course/${courseId}/restore`);
    return response.data;
  },

  // Get all deleted courses
  async getDeletedCourses() {
    const response = await api.get('/course/deleted');
    return response.data;
  },

  // Get available years
  async getAvailableYears() {
    const response = await api.get('/course/years');
    return response.data;
  },

  // Search courses by name
  async searchCoursesByName(name) {
    const response = await api.get(`/course/search/name/${encodeURIComponent(name)}`);
    return response.data;
  },

  // Search courses by year
  async searchCoursesByYear(year) {
    const response = await api.get(`/course/search/year/${encodeURIComponent(year)}`);
    return response.data;
  },

  // Search courses by name and year
  async searchCoursesByNameAndYear(name, year) {
    const response = await api.get(`/course/search/name/${encodeURIComponent(name)}/year/${encodeURIComponent(year)}`);
    return response.data;
  },
};

export default courseService;
