import ballerina/sql;
import ballerinax/mysql;
import ashen/school_performance_panel.database_config;

// Valid test types
public final readonly & string[] VALID_TEST_TYPES = ["tm1", "tm2", "tm3"];

// Database connection class for test operations
public isolated class TestDatabaseConnection {
    private final mysql:Client dbClient;

    public isolated function init() returns error? {
        database_config:DatabaseConfig dbConfig = database_config:getDatabaseConfig();
        self.dbClient = check new (
            host = dbConfig.host,
            port = dbConfig.port,
            user = dbConfig.username,
            password = dbConfig.password,
            database = dbConfig.database
        );
    }

    // Get database client
    public isolated function getClient() returns mysql:Client {
        return self.dbClient;
    }

    // Close database connection
    public isolated function close() returns error? {
        check self.dbClient.close();
    }

    // Validate test type
    public isolated function validateTestType(string testType) returns boolean {
        return VALID_TEST_TYPES.indexOf(testType) != ();
    }

    // Validate that subject exists and is not deleted
    public isolated function validateSubjectExists(int subjectId) returns boolean|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT subject_id 
            FROM subject 
            WHERE subject_id = ${subjectId} AND deleted_at IS NULL
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        record {|record {} value;|}? result = check resultStream.next();
        check resultStream.close();

        if result is () {
            return error("Subject not found or subject is deleted");
        }

        return true;
    }

    // Validate that user exists and is an officer
    public isolated function validateUserIsOfficer(int userId) returns boolean|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT role 
            FROM user 
            WHERE user_id = ${userId} AND deleted_at IS NULL
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        record {|record {} value;|}? result = check resultStream.next();
        check resultStream.close();

        if result is () {
            return error("User not found or user is deleted");
        }

        record {} userData = result.value;
        string userRole = <string>userData["role"];
        
        return userRole == "officer";
    }

    // Validate that test exists and belongs to a valid officer
    public isolated function validateTestBelongsToOfficer(int testId) returns boolean|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT u.role 
            FROM test t 
            JOIN user u ON t.user_id = u.user_id 
            WHERE t.test_id = ${testId} AND t.deleted_at IS NULL AND u.deleted_at IS NULL
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        record {|record {} value;|}? result = check resultStream.next();
        check resultStream.close();

        if result is () {
            return error("Test not found or associated user is deleted");
        }

        record {} userData = result.value;
        string userRole = <string>userData["role"];
        
        return userRole == "officer";
    }

    // Validate that deleted test exists and belongs to a valid officer
    public isolated function validateDeletedTestBelongsToOfficer(int testId) returns boolean|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT u.role 
            FROM test t 
            JOIN user u ON t.user_id = u.user_id 
            WHERE t.test_id = ${testId} AND t.deleted_at IS NOT NULL AND u.deleted_at IS NULL
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        record {|record {} value;|}? result = check resultStream.next();
        check resultStream.close();

        if result is () {
            return error("Deleted test not found or associated user is deleted");
        }

        record {} userData = result.value;
        string userRole = <string>userData["role"];
        
        return userRole == "officer";
    }

    // Add test
    public isolated function addTest(string tName, string tType, string year, int userId, int subjectId) returns Test|error {
        sql:ParameterizedQuery insertQuery = `
            INSERT INTO test (t_name, t_type, year, user_id, subject_id) 
            VALUES (${tName}, ${tType}, ${year}, ${userId}, ${subjectId})
        `;
        sql:ExecutionResult result = check self.dbClient->execute(insertQuery);

        if result.affectedRowCount == 0 {
            return error("Failed to create test");
        }

        int|string? testId = result.lastInsertId;
        if testId is () {
            return error("Failed to get test ID");
        }

        return {
            test_id: <int>testId,
            t_name: tName,
            t_type: tType,
            year: year,
            user_id: userId,
            subject_id: subjectId
        };
    }

    // Update test
    public isolated function updateTest(int testId, string? tName, string? tType, string? year, int? subjectId) returns Test|error {
        sql:ParameterizedQuery updateQuery;
        
        if tName is string && tType is string && year is string && subjectId is int {
            updateQuery = `UPDATE test SET t_name = ${tName}, t_type = ${tType}, year = ${year}, subject_id = ${subjectId}, updated_at = NOW() WHERE test_id = ${testId} AND deleted_at IS NULL`;
        } else if tName is string && tType is string && year is string {
            updateQuery = `UPDATE test SET t_name = ${tName}, t_type = ${tType}, year = ${year}, updated_at = NOW() WHERE test_id = ${testId} AND deleted_at IS NULL`;
        } else if tName is string && tType is string && subjectId is int {
            updateQuery = `UPDATE test SET t_name = ${tName}, t_type = ${tType}, subject_id = ${subjectId}, updated_at = NOW() WHERE test_id = ${testId} AND deleted_at IS NULL`;
        } else if tName is string && year is string && subjectId is int {
            updateQuery = `UPDATE test SET t_name = ${tName}, year = ${year}, subject_id = ${subjectId}, updated_at = NOW() WHERE test_id = ${testId} AND deleted_at IS NULL`;
        } else if tType is string && year is string && subjectId is int {
            updateQuery = `UPDATE test SET t_type = ${tType}, year = ${year}, subject_id = ${subjectId}, updated_at = NOW() WHERE test_id = ${testId} AND deleted_at IS NULL`;
        } else if tName is string && tType is string {
            updateQuery = `UPDATE test SET t_name = ${tName}, t_type = ${tType}, updated_at = NOW() WHERE test_id = ${testId} AND deleted_at IS NULL`;
        } else if tName is string && year is string {
            updateQuery = `UPDATE test SET t_name = ${tName}, year = ${year}, updated_at = NOW() WHERE test_id = ${testId} AND deleted_at IS NULL`;
        } else if tName is string && subjectId is int {
            updateQuery = `UPDATE test SET t_name = ${tName}, subject_id = ${subjectId}, updated_at = NOW() WHERE test_id = ${testId} AND deleted_at IS NULL`;
        } else if tType is string && year is string {
            updateQuery = `UPDATE test SET t_type = ${tType}, year = ${year}, updated_at = NOW() WHERE test_id = ${testId} AND deleted_at IS NULL`;
        } else if tType is string && subjectId is int {
            updateQuery = `UPDATE test SET t_type = ${tType}, subject_id = ${subjectId}, updated_at = NOW() WHERE test_id = ${testId} AND deleted_at IS NULL`;
        } else if year is string && subjectId is int {
            updateQuery = `UPDATE test SET year = ${year}, subject_id = ${subjectId}, updated_at = NOW() WHERE test_id = ${testId} AND deleted_at IS NULL`;
        } else if tName is string {
            updateQuery = `UPDATE test SET t_name = ${tName}, updated_at = NOW() WHERE test_id = ${testId} AND deleted_at IS NULL`;
        } else if tType is string {
            updateQuery = `UPDATE test SET t_type = ${tType}, updated_at = NOW() WHERE test_id = ${testId} AND deleted_at IS NULL`;
        } else if year is string {
            updateQuery = `UPDATE test SET year = ${year}, updated_at = NOW() WHERE test_id = ${testId} AND deleted_at IS NULL`;
        } else if subjectId is int {
            updateQuery = `UPDATE test SET subject_id = ${subjectId}, updated_at = NOW() WHERE test_id = ${testId} AND deleted_at IS NULL`;
        } else {
            return error("No fields to update");
        }

        sql:ExecutionResult result = check self.dbClient->execute(updateQuery);

        if result.affectedRowCount == 0 {
            return error("Test not found or failed to update");
        }

        // Get updated test
        return check self.getTestById(testId);
    }

    // Soft delete test
    public isolated function softDeleteTest(int testId) returns int|error {
        sql:ParameterizedQuery updateQuery = `UPDATE test SET deleted_at = NOW() WHERE test_id = ${testId} AND deleted_at IS NULL`;
        sql:ExecutionResult result = check self.dbClient->execute(updateQuery);

        if result.affectedRowCount == 0 {
            return error("Test not found or already deleted");
        }

        return testId;
    }

    // Restore soft deleted test
    public isolated function restoreTest(int testId) returns Test|error {
        sql:ParameterizedQuery updateQuery = `UPDATE test SET deleted_at = NULL WHERE test_id = ${testId} AND deleted_at IS NOT NULL`;
        sql:ExecutionResult result = check self.dbClient->execute(updateQuery);

        if result.affectedRowCount == 0 {
            return error("Test not found or not deleted");
        }

        // Get restored test
        return check self.getTestById(testId);
    }

    // Get all active tests
    public isolated function getAllTests() returns Test[]|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT test_id, t_name, t_type, year, user_id, subject_id, created_at, updated_at, deleted_at
            FROM test 
            WHERE deleted_at IS NULL
            ORDER BY created_at DESC
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        Test[] tests = [];

        check from record {} testData in resultStream
            do {
                Test test = {
                    test_id: <int>testData["test_id"],
                    t_name: <string>testData["t_name"],
                    t_type: <string>testData["t_type"],
                    year: <string>testData["year"],
                    user_id: <int>testData["user_id"],
                    subject_id: <int>testData["subject_id"],
                    created_at: testData["created_at"].toString(),
                    updated_at: testData["updated_at"].toString(),
                    deleted_at: testData["deleted_at"] is () ? () : testData["deleted_at"].toString()
                };
                tests.push(test);
            };

        return tests;
    }

    // Get test by ID
    public isolated function getTestById(int testId) returns Test|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT test_id, t_name, t_type, year, user_id, subject_id, created_at, updated_at, deleted_at
            FROM test 
            WHERE test_id = ${testId} AND deleted_at IS NULL
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        record {|record {} value;|}? result = check resultStream.next();
        check resultStream.close();

        if result is () {
            return error("Test not found");
        }

        record {} testData = result.value;
        
        return {
            test_id: <int>testData["test_id"],
            t_name: <string>testData["t_name"],
            t_type: <string>testData["t_type"],
            year: <string>testData["year"],
            user_id: <int>testData["user_id"],
            subject_id: <int>testData["subject_id"],
            created_at: testData["created_at"].toString(),
            updated_at: testData["updated_at"].toString(),
            deleted_at: testData["deleted_at"] is () ? () : testData["deleted_at"].toString()
        };
    }

    // Get all deleted tests
    public isolated function getDeletedTests() returns Test[]|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT test_id, t_name, t_type, year, user_id, subject_id, created_at, updated_at, deleted_at
            FROM test 
            WHERE deleted_at IS NOT NULL
            ORDER BY deleted_at DESC
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        Test[] tests = [];

        check from record {} testData in resultStream
            do {
                Test test = {
                    test_id: <int>testData["test_id"],
                    t_name: <string>testData["t_name"],
                    t_type: <string>testData["t_type"],
                    year: <string>testData["year"],
                    user_id: <int>testData["user_id"],
                    subject_id: <int>testData["subject_id"],
                    created_at: testData["created_at"].toString(),
                    updated_at: testData["updated_at"].toString(),
                    deleted_at: testData["deleted_at"] is () ? () : testData["deleted_at"].toString()
                };
                tests.push(test);
            };

        return tests;
    }

    // Get all available years
    public isolated function getAvailableYears() returns string[]|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT DISTINCT year 
            FROM test 
            WHERE deleted_at IS NULL 
            ORDER BY year ASC
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        string[] years = [];

        check from record {} yearData in resultStream
            do {
                string year = <string>yearData["year"];
                years.push(year);
            };

        return years;
    }

    // Get tests by type
    public isolated function getTestsByType(string tType) returns Test[]|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT test_id, t_name, t_type, year, user_id, subject_id, created_at, updated_at, deleted_at
            FROM test 
            WHERE t_type = ${tType} AND deleted_at IS NULL
            ORDER BY created_at DESC
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        Test[] tests = [];

        check from record {} testData in resultStream
            do {
                Test test = {
                    test_id: <int>testData["test_id"],
                    t_name: <string>testData["t_name"],
                    t_type: <string>testData["t_type"],
                    year: <string>testData["year"],
                    user_id: <int>testData["user_id"],
                    subject_id: <int>testData["subject_id"],
                    created_at: testData["created_at"].toString(),
                    updated_at: testData["updated_at"].toString(),
                    deleted_at: testData["deleted_at"] is () ? () : testData["deleted_at"].toString()
                };
                tests.push(test);
            };

        return tests;
    }

    // Search tests by name
    public isolated function searchTestsByName(string namePattern) returns Test[]|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT test_id, t_name, t_type, year, user_id, subject_id, created_at, updated_at, deleted_at
            FROM test 
            WHERE t_name LIKE ${namePattern} AND deleted_at IS NULL
            ORDER BY created_at DESC
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        Test[] tests = [];

        check from record {} testData in resultStream
            do {
                Test test = {
                    test_id: <int>testData["test_id"],
                    t_name: <string>testData["t_name"],
                    t_type: <string>testData["t_type"],
                    year: <string>testData["year"],
                    user_id: <int>testData["user_id"],
                    subject_id: <int>testData["subject_id"],
                    created_at: testData["created_at"].toString(),
                    updated_at: testData["updated_at"].toString(),
                    deleted_at: testData["deleted_at"] is () ? () : testData["deleted_at"].toString()
                };
                tests.push(test);
            };

        return tests;
    }

    // Filter tests by year
    public isolated function filterTestsByYear(string year) returns Test[]|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT test_id, t_name, t_type, year, user_id, subject_id, created_at, updated_at, deleted_at
            FROM test 
            WHERE year = ${year} AND deleted_at IS NULL
            ORDER BY created_at DESC
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        Test[] tests = [];

        check from record {} testData in resultStream
            do {
                Test test = {
                    test_id: <int>testData["test_id"],
                    t_name: <string>testData["t_name"],
                    t_type: <string>testData["t_type"],
                    year: <string>testData["year"],
                    user_id: <int>testData["user_id"],
                    subject_id: <int>testData["subject_id"],
                    created_at: testData["created_at"].toString(),
                    updated_at: testData["updated_at"].toString(),
                    deleted_at: testData["deleted_at"] is () ? () : testData["deleted_at"].toString()
                };
                tests.push(test);
            };

        return tests;
    }

    // Get tests by subject
    public isolated function getTestsBySubject(int subjectId) returns Test[]|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT test_id, t_name, t_type, year, user_id, subject_id, created_at, updated_at, deleted_at
            FROM test 
            WHERE subject_id = ${subjectId} AND deleted_at IS NULL
            ORDER BY created_at DESC
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        Test[] tests = [];

        check from record {} testData in resultStream
            do {
                Test test = {
                    test_id: <int>testData["test_id"],
                    t_name: <string>testData["t_name"],
                    t_type: <string>testData["t_type"],
                    year: <string>testData["year"],
                    user_id: <int>testData["user_id"],
                    subject_id: <int>testData["subject_id"],
                    created_at: testData["created_at"].toString(),
                    updated_at: testData["updated_at"].toString(),
                    deleted_at: testData["deleted_at"] is () ? () : testData["deleted_at"].toString()
                };
                tests.push(test);
            };

        return tests;
    }
}

// Global database connection instance
final TestDatabaseConnection testDbConnection = check new TestDatabaseConnection();
