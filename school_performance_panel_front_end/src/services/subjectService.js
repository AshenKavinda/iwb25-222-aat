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

const subjectService = {
  // Get all subjects
  async getAllSubjects() {
    const response = await api.get('/subject');
    return response.data;
  },

  // Get subject by ID
  async getSubjectById(subjectId) {
    const response = await api.get(`/subject/${subjectId}`);
    return response.data;
  },

  // Add new subject
  async addSubject(subjectData) {
    const response = await api.post('/subject', subjectData);
    return response.data;
  },

  // Update subject
  async updateSubject(subjectId, subjectData) {
    const response = await api.put(`/subject/${subjectId}`, subjectData);
    return response.data;
  },

  // Soft delete subject
  async deleteSubject(subjectId) {
    const response = await api.delete(`/subject/${subjectId}`);
    return response.data;
  },

  // Restore deleted subject
  async restoreSubject(subjectId) {
    const response = await api.post(`/subject/${subjectId}/restore`);
    return response.data;
  },

  // Get all deleted subjects
  async getDeletedSubjects() {
    const response = await api.get('/subject/deleted');
    return response.data;
  },

  // Search subjects by name
  async searchSubjectsByName(name) {
    const response = await api.get(`/subject/search/${encodeURIComponent(name)}`);
    return response.data;
  },
};

export default subjectService;
