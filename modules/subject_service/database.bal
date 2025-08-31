import ballerina/sql;
import ballerinax/mysql;
import ashen/school_performance_panel.database_config;

// Database connection class for subject operations
public isolated class SubjectDatabaseConnection {
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

    // Validate that subject exists and belongs to a valid officer
    public isolated function validateSubjectBelongsToOfficer(int subjectId) returns boolean|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT u.role 
            FROM subject s 
            JOIN user u ON s.user_id = u.user_id 
            WHERE s.subject_id = ${subjectId} AND s.deleted_at IS NULL AND u.deleted_at IS NULL
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        record {|record {} value;|}? result = check resultStream.next();
        check resultStream.close();

        if result is () {
            return error("Subject not found or associated user is deleted");
        }

        record {} userData = result.value;
        string userRole = <string>userData["role"];
        
        return userRole == "officer";
    }

    // Validate that deleted subject exists and belongs to a valid officer
    public isolated function validateDeletedSubjectBelongsToOfficer(int subjectId) returns boolean|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT u.role 
            FROM subject s 
            JOIN user u ON s.user_id = u.user_id 
            WHERE s.subject_id = ${subjectId} AND s.deleted_at IS NOT NULL AND u.deleted_at IS NULL
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        record {|record {} value;|}? result = check resultStream.next();
        check resultStream.close();

        if result is () {
            return error("Deleted subject not found or associated user is deleted");
        }

        record {} userData = result.value;
        string userRole = <string>userData["role"];
        
        return userRole == "officer";
    }

    // Add subject
    public isolated function addSubject(string name, decimal weight, int userId) returns Subject|error {
        sql:ParameterizedQuery insertQuery = `
            INSERT INTO subject (name, weight, user_id) 
            VALUES (${name}, ${weight}, ${userId})
        `;
        sql:ExecutionResult result = check self.dbClient->execute(insertQuery);

        if result.affectedRowCount == 0 {
            return error("Failed to create subject");
        }

        int|string? subjectId = result.lastInsertId;
        if subjectId is () {
            return error("Failed to get subject ID");
        }

        return {
            subject_id: <int>subjectId,
            name: name,
            weight: weight,
            user_id: userId
        };
    }

    // Update subject
    public isolated function updateSubject(int subjectId, string? name, decimal? weight) returns Subject|error {
        sql:ParameterizedQuery updateQuery;
        
        if name is string && weight is decimal {
            updateQuery = `UPDATE subject SET name = ${name}, weight = ${weight}, updated_at = NOW() WHERE subject_id = ${subjectId} AND deleted_at IS NULL`;
        } else if name is string {
            updateQuery = `UPDATE subject SET name = ${name}, updated_at = NOW() WHERE subject_id = ${subjectId} AND deleted_at IS NULL`;
        } else if weight is decimal {
            updateQuery = `UPDATE subject SET weight = ${weight}, updated_at = NOW() WHERE subject_id = ${subjectId} AND deleted_at IS NULL`;
        } else {
            return error("No fields to update");
        }

        sql:ExecutionResult result = check self.dbClient->execute(updateQuery);

        if result.affectedRowCount == 0 {
            return error("Subject not found or failed to update");
        }

        // Get updated subject
        return check self.getSubjectById(subjectId);
    }

    // Soft delete subject
    public isolated function softDeleteSubject(int subjectId) returns int|error {
        sql:ParameterizedQuery updateQuery = `UPDATE subject SET deleted_at = NOW() WHERE subject_id = ${subjectId} AND deleted_at IS NULL`;
        sql:ExecutionResult result = check self.dbClient->execute(updateQuery);

        if result.affectedRowCount == 0 {
            return error("Subject not found or already deleted");
        }

        return subjectId;
    }

    // Restore soft deleted subject
    public isolated function restoreSubject(int subjectId) returns Subject|error {
        sql:ParameterizedQuery updateQuery = `UPDATE subject SET deleted_at = NULL WHERE subject_id = ${subjectId} AND deleted_at IS NOT NULL`;
        sql:ExecutionResult result = check self.dbClient->execute(updateQuery);

        if result.affectedRowCount == 0 {
            return error("Subject not found or not deleted");
        }

        // Get restored subject
        return check self.getSubjectById(subjectId);
    }

    // Get all active subjects
    public isolated function getAllSubjects() returns Subject[]|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT subject_id, name, weight, user_id, created_at, updated_at, deleted_at
            FROM subject 
            WHERE deleted_at IS NULL
            ORDER BY created_at DESC
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        Subject[] subjects = [];

        check from record {} subjectData in resultStream
            do {
                Subject subject = {
                    subject_id: <int>subjectData["subject_id"],
                    name: <string>subjectData["name"],
                    weight: <decimal>subjectData["weight"],
                    user_id: <int>subjectData["user_id"],
                    created_at: subjectData["created_at"].toString(),
                    updated_at: subjectData["updated_at"].toString(),
                    deleted_at: subjectData["deleted_at"] is () ? () : subjectData["deleted_at"].toString()
                };
                subjects.push(subject);
            };

        return subjects;
    }

    // Get subject by ID
    public isolated function getSubjectById(int subjectId) returns Subject|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT subject_id, name, weight, user_id, created_at, updated_at, deleted_at
            FROM subject 
            WHERE subject_id = ${subjectId} AND deleted_at IS NULL
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        record {|record {} value;|}? result = check resultStream.next();
        check resultStream.close();

        if result is () {
            return error("Subject not found");
        }

        record {} subjectData = result.value;
        
        return {
            subject_id: <int>subjectData["subject_id"],
            name: <string>subjectData["name"],
            weight: <decimal>subjectData["weight"],
            user_id: <int>subjectData["user_id"],
            created_at: subjectData["created_at"].toString(),
            updated_at: subjectData["updated_at"].toString(),
            deleted_at: subjectData["deleted_at"] is () ? () : subjectData["deleted_at"].toString()
        };
    }

    // Get all deleted subjects
    public isolated function getDeletedSubjects() returns Subject[]|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT subject_id, name, weight, user_id, created_at, updated_at, deleted_at
            FROM subject 
            WHERE deleted_at IS NOT NULL
            ORDER BY deleted_at DESC
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        Subject[] subjects = [];

        check from record {} subjectData in resultStream
            do {
                Subject subject = {
                    subject_id: <int>subjectData["subject_id"],
                    name: <string>subjectData["name"],
                    weight: <decimal>subjectData["weight"],
                    user_id: <int>subjectData["user_id"],
                    created_at: subjectData["created_at"].toString(),
                    updated_at: subjectData["updated_at"].toString(),
                    deleted_at: subjectData["deleted_at"] is () ? () : subjectData["deleted_at"].toString()
                };
                subjects.push(subject);
            };

        return subjects;
    }

    // Search subjects by name
    public isolated function searchSubjectsByName(string namePattern) returns Subject[]|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT subject_id, name, weight, user_id, created_at, updated_at, deleted_at
            FROM subject 
            WHERE name LIKE ${namePattern} AND deleted_at IS NULL
            ORDER BY created_at DESC
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        Subject[] subjects = [];

        check from record {} subjectData in resultStream
            do {
                Subject subject = {
                    subject_id: <int>subjectData["subject_id"],
                    name: <string>subjectData["name"],
                    weight: <decimal>subjectData["weight"],
                    user_id: <int>subjectData["user_id"],
                    created_at: subjectData["created_at"].toString(),
                    updated_at: subjectData["updated_at"].toString(),
                    deleted_at: subjectData["deleted_at"] is () ? () : subjectData["deleted_at"].toString()
                };
                subjects.push(subject);
            };

        return subjects;
    }
}

// Global database connection instance
final SubjectDatabaseConnection subjectDbConnection = check new SubjectDatabaseConnection();
