import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import ProtectedRoute from './components/ProtectedRoute';
import Login from './components/auth/Login';
import Register from './components/auth/Register';
import Dashboard from './components/dashboards/Dashboard';
import Profile from './components/profile/Profile';
import UpdateMarks from './components/teacher/UpdateMarks';
import StudentManagement from './components/students/StudentManagement';
import SubjectManagement from './components/subjects/SubjectManagement';
import CourseManagement from './components/courses/CourseManagement';
import TestManagement from './components/tests/TestManagement';
import UserManagement from './components/users/UserManagement';
import { useAuth } from './hooks/useAuth';
import './App.css';

const AppRoutes = () => {
  const { isAuthenticated, loading } = useAuth();

  if (loading) {
    return (
      <div className="loading-container">
        <div className="loading-spinner"></div>
        <p>Loading School Performance Panel...</p>
      </div>
    );
  }

  return (
    <Routes>
      {/* Public routes */}
      <Route 
        path="/login" 
        element={isAuthenticated ? <Navigate to="/dashboard" replace /> : <Login />} 
      />
      <Route 
        path="/register" 
        element={isAuthenticated ? <Navigate to="/dashboard" replace /> : <Register />} 
      />
      
      {/* Protected routes */}
      <Route 
        path="/dashboard" 
        element={
          <ProtectedRoute>
            <Dashboard />
          </ProtectedRoute>
        } 
      />
      
      <Route 
        path="/profile" 
        element={
          <ProtectedRoute>
            <Profile />
          </ProtectedRoute>
        } 
      />
      
      <Route 
        path="/update-marks" 
        element={
          <ProtectedRoute>
            <UpdateMarks />
          </ProtectedRoute>
        } 
      />
      
      <Route 
        path="/users" 
        element={
          <ProtectedRoute>
            <UserManagement />
          </ProtectedRoute>
        } 
      />
      
      <Route 
        path="/students" 
        element={
          <ProtectedRoute>
            <StudentManagement />
          </ProtectedRoute>
        } 
      />
      
      <Route 
        path="/subjects" 
        element={
          <ProtectedRoute>
            <SubjectManagement />
          </ProtectedRoute>
        } 
      />
      
      <Route 
        path="/courses" 
        element={
          <ProtectedRoute>
            <CourseManagement />
          </ProtectedRoute>
        } 
      />
      
      <Route 
        path="/tests" 
        element={
          <ProtectedRoute>
            <TestManagement />
          </ProtectedRoute>
        } 
      />
      
      {/* Default redirect */}
      <Route 
        path="/" 
        element={
          isAuthenticated ? 
            <Navigate to="/dashboard" replace /> : 
            <Navigate to="/login" replace />
        } 
      />
      
      {/* Catch all route */}
      <Route 
        path="*" 
        element={
          isAuthenticated ? 
            <Navigate to="/dashboard" replace /> : 
            <Navigate to="/login" replace />
        } 
      />
    </Routes>
  );
};

function App() {
  return (
    <Router>
      <AuthProvider>
        <div className="App">
          <AppRoutes />
        </div>
      </AuthProvider>
    </Router>
  );
}

export default App;
