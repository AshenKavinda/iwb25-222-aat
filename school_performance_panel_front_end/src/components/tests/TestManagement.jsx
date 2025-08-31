import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../../hooks/useAuth';
import testService from '../../services/testService';
import subjectService from '../../services/subjectService';
import TestForm from './TestForm';
import TestList from './TestList';
import './TestManagement.css';

const TestManagement = () => {
  const { user } = useAuth();
  const [tests, setTests] = useState([]);
  const [deletedTests, setDeletedTests] = useState([]);
  const [subjects, setSubjects] = useState([]);
  const [availableYears, setAvailableYears] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [activeTab, setActiveTab] = useState('active'); // 'active' or 'deleted'
  const [showForm, setShowForm] = useState(false);
  const [editingTest, setEditingTest] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [searchResults, setSearchResults] = useState([]);
  const [isSearching, setIsSearching] = useState(false);
  const [filterType, setFilterType] = useState('');
  const [filterYear, setFilterYear] = useState('');
  const [filterSubject, setFilterSubject] = useState('');

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      setError('');
      
      const [testsResponse, deletedResponse, subjectsResponse, yearsResponse] = await Promise.all([
        testService.getAllTests(),
        testService.getDeletedTests(),
        subjectService.getAllSubjects(),
        testService.getAvailableYears()
      ]);

      setTests(testsResponse.data || []);
      setDeletedTests(deletedResponse.data || []);
      setSubjects(subjectsResponse.data || []);
      setAvailableYears(yearsResponse.data || []);
    } catch (err) {
      console.error('Error loading data:', err);
      setError(err.response?.data?.message || 'Failed to load test data');
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = async (term) => {
    if (!term.trim()) {
      setSearchResults([]);
      setIsSearching(false);
      return;
    }

    try {
      setIsSearching(true);
      const response = await testService.searchTestsByName(term);
      setSearchResults(response.data || []);
    } catch (err) {
      console.error('Error searching tests:', err);
      setError(err.response?.data?.message || 'Failed to search tests');
      setSearchResults([]);
    } finally {
      setIsSearching(false);
    }
  };

  const handleFilterByType = async (type) => {
    if (!type) {
      loadData();
      return;
    }

    try {
      setLoading(true);
      const response = await testService.getTestsByType(type);
      setTests(response.data || []);
    } catch (err) {
      console.error('Error filtering by type:', err);
      setError(err.response?.data?.message || 'Failed to filter tests by type');
    } finally {
      setLoading(false);
    }
  };

  const handleFilterByYear = async (year) => {
    if (!year) {
      loadData();
      return;
    }

    try {
      setLoading(true);
      const response = await testService.filterTestsByYear(year);
      setTests(response.data || []);
    } catch (err) {
      console.error('Error filtering by year:', err);
      setError(err.response?.data?.message || 'Failed to filter tests by year');
    } finally {
      setLoading(false);
    }
  };

  const handleFilterBySubject = async (subjectId) => {
    if (!subjectId) {
      loadData();
      return;
    }

    try {
      setLoading(true);
      const response = await testService.getTestsBySubject(parseInt(subjectId));
      setTests(response.data || []);
    } catch (err) {
      console.error('Error filtering by subject:', err);
      setError(err.response?.data?.message || 'Failed to filter tests by subject');
    } finally {
      setLoading(false);
    }
  };

  const handleAddTest = async (testData) => {
    try {
      setError('');
      setSuccess('');
      
      // Add current user's ID as the officer
      const dataWithUserId = {
        ...testData,
        user_id: user.user_id
      };

      await testService.addTest(dataWithUserId);
      setSuccess('Test added successfully!');
      setShowForm(false);
      loadData();
    } catch (err) {
      console.error('Error adding test:', err);
      setError(err.response?.data?.message || 'Failed to add test');
    }
  };

  const handleUpdateTest = async (testData) => {
    try {
      setError('');
      setSuccess('');
      
      await testService.updateTest(editingTest.test_id, testData);
      setSuccess('Test updated successfully!');
      setEditingTest(null);
      setShowForm(false);
      loadData();
    } catch (err) {
      console.error('Error updating test:', err);
      setError(err.response?.data?.message || 'Failed to update test');
    }
  };

  const handleDeleteTest = async (testId) => {
    if (!window.confirm('Are you sure you want to delete this test?')) {
      return;
    }

    try {
      setError('');
      setSuccess('');
      
      await testService.deleteTest(testId);
      setSuccess('Test deleted successfully!');
      loadData();
    } catch (err) {
      console.error('Error deleting test:', err);
      setError(err.response?.data?.message || 'Failed to delete test');
    }
  };

  const handleRestoreTest = async (testId) => {
    if (!window.confirm('Are you sure you want to restore this test?')) {
      return;
    }

    try {
      setError('');
      setSuccess('');
      
      await testService.restoreTest(testId);
      setSuccess('Test restored successfully!');
      loadData();
    } catch (err) {
      console.error('Error restoring test:', err);
      setError(err.response?.data?.message || 'Failed to restore test');
    }
  };

  const handleEditTest = (test) => {
    setEditingTest(test);
    setShowForm(true);
  };

  const handleCancelForm = () => {
    setShowForm(false);
    setEditingTest(null);
  };

  const clearMessages = () => {
    setError('');
    setSuccess('');
  };

  const clearFilters = () => {
    setFilterType('');
    setFilterYear('');
    setFilterSubject('');
    loadData();
  };

  if (loading) {
    return (
      <div className="loading-container">
        <div className="loading-spinner"></div>
        <p>Loading tests...</p>
      </div>
    );
  }

  return (
    <div className="test-management">
      <header className="page-header">
        <div className="header-content">
          <div className="breadcrumb">
            <Link to="/dashboard" className="breadcrumb-link">Dashboard</Link>
            <span className="breadcrumb-separator">›</span>
            <span className="breadcrumb-current">Tests</span>
          </div>
          <h1>Test Management</h1>
          <p>Manage tests and examinations</p>
        </div>
        <div className="header-actions">
          <button 
            onClick={() => setShowForm(true)} 
            className="btn btn-primary"
            disabled={showForm}
          >
            Add New Test
          </button>
        </div>
      </header>

      {/* Messages */}
      {error && (
        <div className="alert alert-error">
          {error}
          <button onClick={clearMessages} className="alert-close">×</button>
        </div>
      )}
      {success && (
        <div className="alert alert-success">
          {success}
          <button onClick={clearMessages} className="alert-close">×</button>
        </div>
      )}

      {/* Test Form */}
      {showForm && (
        <div className="form-section">
          <h2>{editingTest ? 'Edit Test' : 'Add New Test'}</h2>
          <TestForm
            test={editingTest}
            subjects={subjects}
            onSubmit={editingTest ? handleUpdateTest : handleAddTest}
            onCancel={handleCancelForm}
          />
        </div>
      )}

      {/* Filters Section */}
      <div className="filters-section">
        <h3>Filter Tests</h3>
        <div className="filters-grid">
          <div className="filter-group">
            <label htmlFor="filterType" className="filter-label">Test Type</label>
            <select
              id="filterType"
              value={filterType}
              onChange={(e) => {
                setFilterType(e.target.value);
                handleFilterByType(e.target.value);
              }}
              className="filter-select"
            >
              <option value="">All Types</option>
              <option value="tm1">Term 1 (TM1)</option>
              <option value="tm2">Term 2 (TM2)</option>
              <option value="tm3">Term 3 (TM3)</option>
            </select>
          </div>

          <div className="filter-group">
            <label htmlFor="filterYear" className="filter-label">Year</label>
            <select
              id="filterYear"
              value={filterYear}
              onChange={(e) => {
                setFilterYear(e.target.value);
                handleFilterByYear(e.target.value);
              }}
              className="filter-select"
            >
              <option value="">All Years</option>
              {availableYears.map(year => (
                <option key={year} value={year}>{year}</option>
              ))}
            </select>
          </div>

          <div className="filter-group">
            <label htmlFor="filterSubject" className="filter-label">Subject</label>
            <select
              id="filterSubject"
              value={filterSubject}
              onChange={(e) => {
                setFilterSubject(e.target.value);
                handleFilterBySubject(e.target.value);
              }}
              className="filter-select"
            >
              <option value="">All Subjects</option>
              {subjects.map(subject => (
                <option key={subject.subject_id} value={subject.subject_id}>
                  {subject.name}
                </option>
              ))}
            </select>
          </div>

          <div className="filter-actions">
            <button onClick={clearFilters} className="btn btn-secondary btn-sm">
              Clear Filters
            </button>
          </div>
        </div>
      </div>

      {/* Search Section */}
      <div className="search-section">
        <h3>Search Tests</h3>
        <div className="search-input-group">
          <input
            type="text"
            placeholder="Search by test name..."
            value={searchTerm}
            onChange={(e) => {
              setSearchTerm(e.target.value);
              handleSearch(e.target.value);
            }}
            className="search-input"
          />
          {isSearching && <div className="search-spinner">🔍</div>}
        </div>
        
        {searchResults.length > 0 && (
          <div className="search-results">
            <h4>Search Results ({searchResults.length})</h4>
            <TestList
              tests={searchResults}
              subjects={subjects}
              onEdit={handleEditTest}
              onDelete={handleDeleteTest}
              showActions={true}
            />
          </div>
        )}
      </div>

      {/* Tab Navigation */}
      <div className="tab-navigation">
        <button 
          className={`tab-button ${activeTab === 'active' ? 'active' : ''}`}
          onClick={() => setActiveTab('active')}
        >
          Active Tests ({tests.length})
        </button>
        <button 
          className={`tab-button ${activeTab === 'deleted' ? 'active' : ''}`}
          onClick={() => setActiveTab('deleted')}
        >
          Deleted Tests ({deletedTests.length})
        </button>
      </div>

      {/* Test Lists */}
      <div className="tab-content">
        {activeTab === 'active' && (
          <div className="tab-panel">
            <div className="section-header">
              <h3>Active Tests</h3>
              <p>{tests.length} tests found</p>
            </div>
            <TestList
              tests={tests}
              subjects={subjects}
              onEdit={handleEditTest}
              onDelete={handleDeleteTest}
              showActions={true}
            />
          </div>
        )}

        {activeTab === 'deleted' && (
          <div className="tab-panel">
            <div className="section-header">
              <h3>Deleted Tests</h3>
              <p>{deletedTests.length} deleted tests found</p>
            </div>
            <TestList
              tests={deletedTests}
              subjects={subjects}
              onRestore={handleRestoreTest}
              showActions={true}
              isDeleted={true}
            />
          </div>
        )}
      </div>
    </div>
  );
};

export default TestManagement;
