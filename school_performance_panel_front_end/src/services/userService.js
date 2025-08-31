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

const userService = {
  // Get all active users
  async getAllUsers() {
    const response = await api.get('/user');
    return response.data;
  },

  // Get user by ID
  async getUserById(userId) {
    const response = await api.get(`/user/${userId}`);
    return response.data;
  },

  // Add new user
  async addUser(userData) {
    const response = await api.post('/user', userData);
    return response.data;
  },

  // Update user
  async updateUser(userId, userData) {
    const response = await api.put(`/user/${userId}`, userData);
    return response.data;
  },

  // Soft delete user
  async deleteUser(userId) {
    const response = await api.delete(`/user/${userId}`);
    return response.data;
  },

  // Restore deleted user
  async restoreUser(userId) {
    const response = await api.post(`/user/${userId}/restore`);
    return response.data;
  },

  // Get all deleted users
  async getDeletedUsers() {
    const response = await api.get('/user/deleted');
    return response.data;
  },

  // Search users by email
  async searchUsersByEmail(email) {
    const response = await api.get(`/user/search?email=${encodeURIComponent(email)}`);
    return response.data;
  },
};

export default userService;
