import ballerina/sql;
import ballerinax/mysql;
import ashen/school_performance_panel.database_config;

// Database connection class for student operations
public isolated class StudentDatabaseConnection {
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

    // Validate that student exists and belongs to a valid officer
    public isolated function validateStudentBelongsToOfficer(int studentId) returns boolean|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT u.role 
            FROM student s 
            JOIN user u ON s.user_id = u.user_id 
            WHERE s.student_id = ${studentId} AND s.deleted_at IS NULL AND u.deleted_at IS NULL
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        record {|record {} value;|}? result = check resultStream.next();
        check resultStream.close();

        if result is () {
            return error("Student not found or associated user is deleted");
        }

        record {} userData = result.value;
        string userRole = <string>userData["role"];
        
        return userRole == "officer";
    }

    // Validate that deleted student exists and belongs to a valid officer
    public isolated function validateDeletedStudentBelongsToOfficer(int studentId) returns boolean|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT u.role 
            FROM student s 
            JOIN user u ON s.user_id = u.user_id 
            WHERE s.student_id = ${studentId} AND s.deleted_at IS NOT NULL AND u.deleted_at IS NULL
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        record {|record {} value;|}? result = check resultStream.next();
        check resultStream.close();

        if result is () {
            return error("Deleted student not found or associated user is deleted");
        }

        record {} userData = result.value;
        string userRole = <string>userData["role"];
        
        return userRole == "officer";
    }

    // Add student
    public isolated function addStudent(string parentNic, string fullName, string dob, int userId) returns Student|error {
        sql:ParameterizedQuery insertQuery = `
            INSERT INTO student (parent_nic, full_name, dob, user_id) 
            VALUES (${parentNic}, ${fullName}, ${dob}, ${userId})
        `;
        sql:ExecutionResult result = check self.dbClient->execute(insertQuery);

        if result.affectedRowCount == 0 {
            return error("Failed to create student");
        }

        int|string? studentId = result.lastInsertId;
        if studentId is () {
            return error("Failed to get student ID");
        }

        return {
            student_id: <int>studentId,
            parent_nic: parentNic,
            full_name: fullName,
            dob: dob,
            user_id: userId
        };
    }

    // Update student
    public isolated function updateStudent(int studentId, string? parentNic, string? fullName, string? dob) returns Student|error {
        sql:ParameterizedQuery updateQuery;
        
        if parentNic is string && fullName is string && dob is string {
            updateQuery = `UPDATE student SET parent_nic = ${parentNic}, full_name = ${fullName}, dob = ${dob}, updated_at = NOW() WHERE student_id = ${studentId} AND deleted_at IS NULL`;
        } else if parentNic is string && fullName is string {
            updateQuery = `UPDATE student SET parent_nic = ${parentNic}, full_name = ${fullName}, updated_at = NOW() WHERE student_id = ${studentId} AND deleted_at IS NULL`;
        } else if parentNic is string && dob is string {
            updateQuery = `UPDATE student SET parent_nic = ${parentNic}, dob = ${dob}, updated_at = NOW() WHERE student_id = ${studentId} AND deleted_at IS NULL`;
        } else if fullName is string && dob is string {
            updateQuery = `UPDATE student SET full_name = ${fullName}, dob = ${dob}, updated_at = NOW() WHERE student_id = ${studentId} AND deleted_at IS NULL`;
        } else if parentNic is string {
            updateQuery = `UPDATE student SET parent_nic = ${parentNic}, updated_at = NOW() WHERE student_id = ${studentId} AND deleted_at IS NULL`;
        } else if fullName is string {
            updateQuery = `UPDATE student SET full_name = ${fullName}, updated_at = NOW() WHERE student_id = ${studentId} AND deleted_at IS NULL`;
        } else if dob is string {
            updateQuery = `UPDATE student SET dob = ${dob}, updated_at = NOW() WHERE student_id = ${studentId} AND deleted_at IS NULL`;
        } else {
            return error("No fields to update");
        }

        sql:ExecutionResult result = check self.dbClient->execute(updateQuery);

        if result.affectedRowCount == 0 {
            return error("Student not found or failed to update");
        }

        // Get updated student
        return check self.getStudentById(studentId);
    }

    // Soft delete student
    public isolated function softDeleteStudent(int studentId) returns int|error {
        sql:ParameterizedQuery updateQuery = `UPDATE student SET deleted_at = NOW() WHERE student_id = ${studentId} AND deleted_at IS NULL`;
        sql:ExecutionResult result = check self.dbClient->execute(updateQuery);

        if result.affectedRowCount == 0 {
            return error("Student not found or already deleted");
        }

        return studentId;
    }

    // Restore soft deleted student
    public isolated function restoreStudent(int studentId) returns Student|error {
        sql:ParameterizedQuery updateQuery = `UPDATE student SET deleted_at = NULL WHERE student_id = ${studentId} AND deleted_at IS NOT NULL`;
        sql:ExecutionResult result = check self.dbClient->execute(updateQuery);

        if result.affectedRowCount == 0 {
            return error("Student not found or not deleted");
        }

        // Get restored student
        return check self.getStudentById(studentId);
    }

    // Get all active students
    public isolated function getAllStudents() returns Student[]|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT student_id, parent_nic, full_name, dob, user_id, created_at, updated_at, deleted_at
            FROM student 
            WHERE deleted_at IS NULL
            ORDER BY created_at DESC
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        Student[] students = [];

        check from record {} studentData in resultStream
            do {
                Student student = {
                    student_id: <int>studentData["student_id"],
                    parent_nic: <string>studentData["parent_nic"],
                    full_name: <string>studentData["full_name"],
                    dob: <string>studentData["dob"],
                    user_id: <int>studentData["user_id"],
                    created_at: studentData["created_at"].toString(),
                    updated_at: studentData["updated_at"].toString(),
                    deleted_at: studentData["deleted_at"] is () ? () : studentData["deleted_at"].toString()
                };
                students.push(student);
            };

        return students;
    }

    // Get student by ID
    public isolated function getStudentById(int studentId) returns Student|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT student_id, parent_nic, full_name, dob, user_id, created_at, updated_at, deleted_at
            FROM student 
            WHERE student_id = ${studentId} AND deleted_at IS NULL
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        record {|record {} value;|}? result = check resultStream.next();
        check resultStream.close();

        if result is () {
            return error("Student not found");
        }

        record {} studentData = result.value;
        
        return {
            student_id: <int>studentData["student_id"],
            parent_nic: <string>studentData["parent_nic"],
            full_name: <string>studentData["full_name"],
            dob: <string>studentData["dob"],
            user_id: <int>studentData["user_id"],
            created_at: studentData["created_at"].toString(),
            updated_at: studentData["updated_at"].toString(),
            deleted_at: studentData["deleted_at"] is () ? () : studentData["deleted_at"].toString()
        };
    }

    // Get all deleted students
    public isolated function getDeletedStudents() returns Student[]|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT student_id, parent_nic, full_name, dob, user_id, created_at, updated_at, deleted_at
            FROM student 
            WHERE deleted_at IS NOT NULL
            ORDER BY deleted_at DESC
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        Student[] students = [];

        check from record {} studentData in resultStream
            do {
                Student student = {
                    student_id: <int>studentData["student_id"],
                    parent_nic: <string>studentData["parent_nic"],
                    full_name: <string>studentData["full_name"],
                    dob: <string>studentData["dob"],
                    user_id: <int>studentData["user_id"],
                    created_at: studentData["created_at"].toString(),
                    updated_at: studentData["updated_at"].toString(),
                    deleted_at: studentData["deleted_at"] is () ? () : studentData["deleted_at"].toString()
                };
                students.push(student);
            };

        return students;
    }

    // Search students by full name
    public isolated function searchStudentsByName(string namePattern) returns Student[]|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT student_id, parent_nic, full_name, dob, user_id, created_at, updated_at, deleted_at
            FROM student 
            WHERE full_name LIKE ${namePattern} AND deleted_at IS NULL
            ORDER BY created_at DESC
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        Student[] students = [];

        check from record {} studentData in resultStream
            do {
                Student student = {
                    student_id: <int>studentData["student_id"],
                    parent_nic: <string>studentData["parent_nic"],
                    full_name: <string>studentData["full_name"],
                    dob: <string>studentData["dob"],
                    user_id: <int>studentData["user_id"],
                    created_at: studentData["created_at"].toString(),
                    updated_at: studentData["updated_at"].toString(),
                    deleted_at: studentData["deleted_at"] is () ? () : studentData["deleted_at"].toString()
                };
                students.push(student);
            };

        return students;
    }
}

// Global database connection instance
final StudentDatabaseConnection studentDbConnection = check new StudentDatabaseConnection();
