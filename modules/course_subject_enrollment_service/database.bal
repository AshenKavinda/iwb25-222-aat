import ballerina/sql;
import ballerinax/mysql;
import ashen/school_performance_panel.database_config;

// Database connection class for course subject enrollment operations
public isolated class CourseSubjectEnrollmentDatabaseConnection {
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

    // Validate that user exists and is a teacher
    public isolated function validateUserIsTeacher(int userId) returns boolean|error {
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
        
        return userRole == "teacher";
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

        return result is record {};
    }

    // Validate that course exists and is not deleted
    public isolated function validateCourseExists(int courseId) returns boolean|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT course_id 
            FROM course 
            WHERE course_id = ${courseId} AND deleted_at IS NULL
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        record {|record {} value;|}? result = check resultStream.next();
        check resultStream.close();

        return result is record {};
    }

    // Check if subject-course-teacher combination already exists
    public isolated function isCombinationAlreadyExists(int subjectId, int courseId, int teacherId) returns boolean|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT record_id 
            FROM subject_course_teacher 
            WHERE subject_id = ${subjectId} AND course_id = ${courseId} AND teacher_id = ${teacherId}
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        record {|record {} value;|}? result = check resultStream.next();
        check resultStream.close();

        return result is record {};
    }

    // Add course subject enrollment
    public isolated function addCourseSubjectEnrollment(int subjectId, int courseId, int teacherId, int userId) returns CourseSubjectEnrollment|error {
        // Check if combination already exists
        boolean|error alreadyExists = self.isCombinationAlreadyExists(subjectId, courseId, teacherId);
        
        if alreadyExists is error {
            return error("Error checking if combination already exists");
        }
        
        if alreadyExists {
            return error("Subject-Course-Teacher combination already exists");
        }
        
        sql:ParameterizedQuery insertQuery = `
            INSERT INTO subject_course_teacher (subject_id, course_id, teacher_id, user_id) 
            VALUES (${subjectId}, ${courseId}, ${teacherId}, ${userId})
        `;
        sql:ExecutionResult result = check self.dbClient->execute(insertQuery);

        if result.affectedRowCount == 0 {
            return error("Failed to add course subject enrollment");
        }

        int|string? recordId = result.lastInsertId;
        if recordId is () {
            return error("Failed to get record ID");
        }

        return {
            record_id: <int>recordId,
            subject_id: subjectId,
            course_id: courseId,
            teacher_id: teacherId,
            user_id: userId
        };
    }

    // Update course subject enrollment record (only subject_id field)
    public isolated function updateCourseSubjectEnrollment(int recordId, int subjectId) returns CourseSubjectEnrollment|error {
        // Get current record to check course_id and teacher_id
        sql:ParameterizedQuery getCurrentQuery = `
            SELECT course_id, teacher_id 
            FROM subject_course_teacher 
            WHERE record_id = ${recordId}
        `;
        
        stream<record {}, error?> currentStream = self.dbClient->query(getCurrentQuery);
        record {|record {} value;|}? currentResult = check currentStream.next();
        check currentStream.close();

        if currentResult is () {
            return error("Course subject enrollment record not found");
        }

        record {} currentData = currentResult.value;
        int courseId = <int>currentData["course_id"];
        int teacherId = <int>currentData["teacher_id"];

        // Check if new combination would already exist (excluding current record)
        sql:ParameterizedQuery checkQuery = `
            SELECT record_id 
            FROM subject_course_teacher 
            WHERE subject_id = ${subjectId} AND course_id = ${courseId} AND teacher_id = ${teacherId} AND record_id != ${recordId}
        `;
        stream<record {}, error?> checkStream = self.dbClient->query(checkQuery);
        record {|record {} value;|}? duplicateCheck = check checkStream.next();
        check checkStream.close();
        
        if duplicateCheck is record {} {
            return error("Subject-Course-Teacher combination already exists");
        }

        sql:ParameterizedQuery updateQuery = `
            UPDATE subject_course_teacher 
            SET subject_id = ${subjectId}, updated_at = NOW() 
            WHERE record_id = ${recordId}
        `;

        sql:ExecutionResult result = check self.dbClient->execute(updateQuery);

        if result.affectedRowCount == 0 {
            return error("Course subject enrollment record not found or failed to update");
        }

        // Get updated record
        return check self.getCourseSubjectEnrollmentById(recordId);
    }

    // Delete course subject enrollment record (hard delete)
    public isolated function deleteCourseSubjectEnrollment(int recordId) returns int|error {
        sql:ParameterizedQuery deleteQuery = `DELETE FROM subject_course_teacher WHERE record_id = ${recordId}`;
        sql:ExecutionResult result = check self.dbClient->execute(deleteQuery);

        if result.affectedRowCount == 0 {
            return error("Course subject enrollment record not found");
        }

        return recordId;
    }

    // Get course subject enrollment by record ID
    public isolated function getCourseSubjectEnrollmentById(int recordId) returns CourseSubjectEnrollment|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT record_id, subject_id, course_id, teacher_id, user_id, created_at, updated_at
            FROM subject_course_teacher 
            WHERE record_id = ${recordId}
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        record {|record {} value;|}? result = check resultStream.next();
        check resultStream.close();

        if result is () {
            return error("Course subject enrollment record not found");
        }

        record {} recordData = result.value;
        
        return {
            record_id: <int>recordData["record_id"],
            subject_id: <int>recordData["subject_id"],
            course_id: <int>recordData["course_id"],
            teacher_id: <int>recordData["teacher_id"],
            user_id: <int>recordData["user_id"],
            created_at: recordData["created_at"].toString(),
            updated_at: recordData["updated_at"].toString()
        };
    }

    // Get all course subject enrollments by course ID
    public isolated function getCourseSubjectEnrollmentsByCourseId(int courseId) returns CourseSubjectEnrollment[]|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT record_id, subject_id, course_id, teacher_id, user_id, created_at, updated_at
            FROM subject_course_teacher 
            WHERE course_id = ${courseId}
            ORDER BY created_at DESC
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        CourseSubjectEnrollment[] enrollments = [];

        check from record {} recordData in resultStream
            do {
                CourseSubjectEnrollment enrollment = {
                    record_id: <int>recordData["record_id"],
                    subject_id: <int>recordData["subject_id"],
                    course_id: <int>recordData["course_id"],
                    teacher_id: <int>recordData["teacher_id"],
                    user_id: <int>recordData["user_id"],
                    created_at: recordData["created_at"].toString(),
                    updated_at: recordData["updated_at"].toString()
                };
                enrollments.push(enrollment);
            };

        return enrollments;
    }

    // Get course subject enrollments with details by teacher ID
    public isolated function getCourseSubjectEnrollmentsByTeacherId(int teacherId) returns CourseSubjectEnrollmentWithDetails[]|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT 
                sct.record_id,
                sct.subject_id,
                s.name as subject_name,
                s.weight as subject_weight,
                sct.course_id,
                c.name as course_name,
                c.year as course_year,
                c.hall as course_hall,
                sct.teacher_id,
                CONCAT(p.name) as teacher_name,
                sct.user_id,
                sct.created_at,
                sct.updated_at
            FROM subject_course_teacher sct
            JOIN subject s ON sct.subject_id = s.subject_id AND s.deleted_at IS NULL
            JOIN course c ON sct.course_id = c.course_id AND c.deleted_at IS NULL
            JOIN user u ON sct.teacher_id = u.user_id AND u.deleted_at IS NULL
            JOIN profile p ON u.user_id = p.user_id AND p.deleted_at IS NULL
            WHERE sct.teacher_id = ${teacherId}
            ORDER BY sct.created_at DESC
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        CourseSubjectEnrollmentWithDetails[] enrollments = [];

        check from record {} recordData in resultStream
            do {
                CourseSubjectEnrollmentWithDetails enrollment = {
                    record_id: <int>recordData["record_id"],
                    subject_id: <int>recordData["subject_id"],
                    subject_name: <string>recordData["subject_name"],
                    subject_weight: recordData["subject_weight"] is () ? () : <decimal>recordData["subject_weight"],
                    course_id: <int>recordData["course_id"],
                    course_name: <string>recordData["course_name"],
                    course_year: <string>recordData["course_year"],
                    course_hall: recordData["course_hall"] is () ? () : <string>recordData["course_hall"],
                    teacher_id: <int>recordData["teacher_id"],
                    teacher_name: <string>recordData["teacher_name"],
                    user_id: <int>recordData["user_id"],
                    created_at: recordData["created_at"].toString(),
                    updated_at: recordData["updated_at"].toString()
                };
                enrollments.push(enrollment);
            };

        return enrollments;
    }
}

// Global database connection instance
final CourseSubjectEnrollmentDatabaseConnection courseSubjectEnrollmentDbConnection = check new CourseSubjectEnrollmentDatabaseConnection();
