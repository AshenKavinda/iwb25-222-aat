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

const testService = {
  // Get all tests
  async getAllTests() {
    const response = await api.get('/test');
    return response.data;
  },

  // Get test by ID
  async getTestById(testId) {
    const response = await api.get(`/test/${testId}`);
    return response.data;
  },

  // Add new test
  async addTest(testData) {
    const response = await api.post('/test', testData);
    return response.data;
  },

  // Update test
  async updateTest(testId, testData) {
    const response = await api.put(`/test/${testId}`, testData);
    return response.data;
  },

  // Soft delete test
  async deleteTest(testId) {
    const response = await api.delete(`/test/${testId}`);
    return response.data;
  },

  // Restore deleted test
  async restoreTest(testId) {
    const response = await api.post(`/test/${testId}/restore`);
    return response.data;
  },

  // Get all deleted tests
  async getDeletedTests() {
    const response = await api.get('/test/deleted');
    return response.data;
  },

  // Get all available years
  async getAvailableYears() {
    const response = await api.get('/test/years');
    return response.data;
  },

  // Get tests by type
  async getTestsByType(testType) {
    const response = await api.get(`/test/types/${testType}`);
    return response.data;
  },

  // Filter tests by year
  async filterTestsByYear(year) {
    const response = await api.get(`/test/year/${year}`);
    return response.data;
  },

  // Search tests by name
  async searchTestsByName(name) {
    const response = await api.get(`/test/search/name/${encodeURIComponent(name)}`);
    return response.data;
  },

  // Get tests by subject
  async getTestsBySubject(subjectId) {
    const response = await api.get(`/test/subject/${subjectId}`);
    return response.data;
  },
};

export default testService;
