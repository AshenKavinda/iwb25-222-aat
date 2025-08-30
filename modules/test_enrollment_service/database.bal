import ballerina/sql;
import ballerinax/mysql;

// Database configuration
configurable string DB_HOST = "127.0.0.1";
configurable int DB_PORT = 3306;
configurable string DB_USERNAME = "root";
configurable string DB_PASSWORD = "Ashen#321";
configurable string DB_NAME = "school_performance";

// Database connection class for test enrollment operations
public isolated class TestEnrollmentDatabaseConnection {
    private final mysql:Client dbClient;

    public isolated function init() returns error? {
        self.dbClient = check new (
            host = DB_HOST,
            port = DB_PORT,
            user = DB_USERNAME,
            password = DB_PASSWORD,
            database = DB_NAME
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

    // Validate that course exists
    public isolated function validateCourseExists(int courseId) returns boolean|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT course_id 
            FROM course 
            WHERE course_id = ${courseId} AND deleted_at IS NULL
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        record {|record {} value;|}? result = check resultStream.next();
        check resultStream.close();

        return result is record {|record {} value;|};
    }

    // Get test information with subject details
    public isolated function getTestsWithSubjects(int[] testIds) returns TestInfo[]|error {
        if testIds.length() == 0 {
            return error("Test IDs array cannot be empty");
        }

        TestInfo[] allTests = [];
        
        // Query each test individually to avoid IN clause complexity
        foreach int testId in testIds {
            sql:ParameterizedQuery selectQuery = `
                SELECT t.test_id, t.t_name, t.t_type, t.year, t.subject_id, s.name as subject_name
                FROM test t
                JOIN subject s ON t.subject_id = s.subject_id
                WHERE t.test_id = ${testId} AND t.deleted_at IS NULL AND s.deleted_at IS NULL
            `;
            
            stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
            record {|record {} value;|}? result = check resultStream.next();
            check resultStream.close();

            if result is record {|record {} value;|} {
                record {} testData = result.value;
                TestInfo test = {
                    test_id: <int>testData["test_id"],
                    t_name: <string>testData["t_name"],
                    t_type: <string>testData["t_type"],
                    year: <string>testData["year"],
                    subject_id: <int>testData["subject_id"],
                    subject_name: <string>testData["subject_name"]
                };
                allTests.push(test);
            }
        }

        return allTests;
    }

    // Get students enrolled in specific subjects for a course
    public isolated function getStudentsForSubjectsInCourse(int courseId, int[] subjectIds) returns StudentInfo[]|error {
        if subjectIds.length() == 0 {
            return error("Subject IDs array cannot be empty");
        }

        StudentInfo[] allStudents = [];
        map<boolean> uniqueStudents = {};
        
        // Query for each subject individually to avoid IN clause complexity
        foreach int subjectId in subjectIds {
            sql:ParameterizedQuery selectQuery = `
                SELECT s.student_id, s.full_name
                FROM student s
                JOIN student_subject_course ssc ON s.student_id = ssc.student_id
                WHERE ssc.course_id = ${courseId} 
                AND ssc.subject_id = ${subjectId}
                AND s.deleted_at IS NULL
            `;
            
            stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);

            check from record {} studentData in resultStream
                do {
                    int studentId = <int>studentData["student_id"];
                    string studentIdStr = studentId.toString();
                    
                    // Only add if not already added (to avoid duplicates)
                    if !uniqueStudents.hasKey(studentIdStr) {
                        StudentInfo student = {
                            student_id: studentId,
                            full_name: <string>studentData["full_name"]
                        };
                        allStudents.push(student);
                        uniqueStudents[studentIdStr] = true;
                    }
                };
        }

        return allStudents;
    }

    // Add test enrollment record
    public isolated function addTestEnrollment(int studentId, int courseId, int subjectId, int testId, int userId) returns int|error {
        // Check if enrollment already exists
        sql:ParameterizedQuery checkQuery = `
            SELECT record_id 
            FROM student_test_course_subject 
            WHERE student_id = ${studentId} AND course_id = ${courseId} 
            AND subject_id = ${subjectId} AND test_id = ${testId}
        `;
        
        stream<record {}, error?> checkStream = self.dbClient->query(checkQuery);
        record {|record {} value;|}? existingRecord = check checkStream.next();
        check checkStream.close();

        if existingRecord is record {|record {} value;|} {
            return error("Test enrollment already exists for this student, course, subject, and test combination");
        }

        sql:ParameterizedQuery insertQuery = `
            INSERT INTO student_test_course_subject (student_id, course_id, subject_id, test_id, user_id) 
            VALUES (${studentId}, ${courseId}, ${subjectId}, ${testId}, ${userId})
        `;
        sql:ExecutionResult result = check self.dbClient->execute(insertQuery);

        if result.affectedRowCount == 0 {
            return error("Failed to create test enrollment");
        }

        int|string? recordId = result.lastInsertId;
        if recordId is () {
            return error("Failed to get enrollment record ID");
        }

        return <int>recordId;
    }

    // Delete test enrollment records
    public isolated function deleteTestEnrollments(int courseId, int[] testIds) returns int|error {
        if testIds.length() == 0 {
            return error("Test IDs array cannot be empty");
        }

        int totalDeleted = 0;
        
        // Delete for each test individually to avoid IN clause complexity
        foreach int testId in testIds {
            sql:ParameterizedQuery deleteQuery = `
                DELETE FROM student_test_course_subject 
                WHERE course_id = ${courseId} AND test_id = ${testId}
            `;
            sql:ExecutionResult result = check self.dbClient->execute(deleteQuery);
            totalDeleted += <int>result.affectedRowCount;
        }

        return totalDeleted;
    }

    // Get course name
    public isolated function getCourseName(int courseId) returns string|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT name 
            FROM course 
            WHERE course_id = ${courseId} AND deleted_at IS NULL
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        record {|record {} value;|}? result = check resultStream.next();
        check resultStream.close();

        if result is () {
            return error("Course not found");
        }

        record {} courseData = result.value;
        return <string>courseData["name"];
    }

    // Get subject names
    public isolated function getSubjectNames(int[] subjectIds) returns string[]|error {
        if subjectIds.length() == 0 {
            return [];
        }

        string[] subjectNames = [];
        
        // Query each subject individually to avoid IN clause complexity
        foreach int subjectId in subjectIds {
            sql:ParameterizedQuery selectQuery = `
                SELECT name 
                FROM subject 
                WHERE subject_id = ${subjectId} AND deleted_at IS NULL
            `;
            
            stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
            record {|record {} value;|}? result = check resultStream.next();
            check resultStream.close();

            if result is record {|record {} value;|} {
                record {} subjectData = result.value;
                string subjectName = <string>subjectData["name"];
                subjectNames.push(subjectName);
            }
        }

        return subjectNames;
    }

    // Validate that user exists and is an officer or teacher
    public isolated function validateUserIsOfficerOrTeacher(int userId) returns boolean|error {
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
        
        return userRole == "officer" || userRole == "teacher";
    }

    // Get test enrollments by course ID and test ID with detailed information
    public isolated function getTestEnrollmentsByCourseAndTest(int courseId, int testId) returns TestEnrollmentWithDetails[]|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT 
                stcs.record_id,
                stcs.student_id,
                s.full_name as student_name,
                stcs.course_id,
                c.name as course_name,
                stcs.subject_id,
                sub.name as subject_name,
                stcs.test_id,
                t.t_name as test_name,
                t.t_type as test_type,
                stcs.mark,
                stcs.created_at,
                stcs.updated_at
            FROM student_test_course_subject stcs
            JOIN student s ON stcs.student_id = s.student_id
            JOIN course c ON stcs.course_id = c.course_id
            JOIN subject sub ON stcs.subject_id = sub.subject_id
            JOIN test t ON stcs.test_id = t.test_id
            WHERE stcs.course_id = ${courseId} 
            AND stcs.test_id = ${testId}
            AND s.deleted_at IS NULL
            AND c.deleted_at IS NULL
            AND sub.deleted_at IS NULL
            AND t.deleted_at IS NULL
            ORDER BY s.full_name ASC
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        TestEnrollmentWithDetails[] enrollments = [];

        check from record {} enrollmentData in resultStream
            do {
                TestEnrollmentWithDetails enrollment = {
                    record_id: <int>enrollmentData["record_id"],
                    student_id: <int>enrollmentData["student_id"],
                    student_name: <string>enrollmentData["student_name"],
                    course_id: <int>enrollmentData["course_id"],
                    course_name: <string>enrollmentData["course_name"],
                    subject_id: <int>enrollmentData["subject_id"],
                    subject_name: <string>enrollmentData["subject_name"],
                    test_id: <int>enrollmentData["test_id"],
                    test_name: <string>enrollmentData["test_name"],
                    test_type: <string>enrollmentData["test_type"],
                    mark: enrollmentData["mark"] is () ? () : <decimal>enrollmentData["mark"],
                    created_at: enrollmentData["created_at"].toString(),
                    updated_at: enrollmentData["updated_at"].toString()
                };
                enrollments.push(enrollment);
            };

        return enrollments;
    }

    // Get test enrollment by record ID with detailed information
    public isolated function getTestEnrollmentByRecordId(int recordId) returns TestEnrollmentWithDetails|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT 
                stcs.record_id,
                stcs.student_id,
                s.full_name as student_name,
                stcs.course_id,
                c.name as course_name,
                stcs.subject_id,
                sub.name as subject_name,
                stcs.test_id,
                t.t_name as test_name,
                t.t_type as test_type,
                stcs.mark,
                stcs.created_at,
                stcs.updated_at
            FROM student_test_course_subject stcs
            JOIN student s ON stcs.student_id = s.student_id
            JOIN course c ON stcs.course_id = c.course_id
            JOIN subject sub ON stcs.subject_id = sub.subject_id
            JOIN test t ON stcs.test_id = t.test_id
            WHERE stcs.record_id = ${recordId}
            AND s.deleted_at IS NULL
            AND c.deleted_at IS NULL
            AND sub.deleted_at IS NULL
            AND t.deleted_at IS NULL
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        record {|record {} value;|}? result = check resultStream.next();
        check resultStream.close();

        if result is () {
            return error("Test enrollment record not found");
        }

        record {} enrollmentData = result.value;
        
        return {
            record_id: <int>enrollmentData["record_id"],
            student_id: <int>enrollmentData["student_id"],
            student_name: <string>enrollmentData["student_name"],
            course_id: <int>enrollmentData["course_id"],
            course_name: <string>enrollmentData["course_name"],
            subject_id: <int>enrollmentData["subject_id"],
            subject_name: <string>enrollmentData["subject_name"],
            test_id: <int>enrollmentData["test_id"],
            test_name: <string>enrollmentData["test_name"],
            test_type: <string>enrollmentData["test_type"],
            mark: enrollmentData["mark"] is () ? () : <decimal>enrollmentData["mark"],
            created_at: enrollmentData["created_at"].toString(),
            updated_at: enrollmentData["updated_at"].toString()
        };
    }

    // Update mark for a test enrollment
    public isolated function updateMark(int recordId, decimal mark) returns TestEnrollmentWithDetails|error {
        // Validate mark is between 0 and 100
        decimal minMark = 0.0d;
        decimal maxMark = 100.0d;
        if mark < minMark || mark > maxMark {
            return error("Mark must be between 0 and 100");
        }

        sql:ParameterizedQuery updateQuery = `
            UPDATE student_test_course_subject 
            SET mark = ${mark}, updated_at = NOW() 
            WHERE record_id = ${recordId}
        `;
        sql:ExecutionResult result = check self.dbClient->execute(updateQuery);

        if result.affectedRowCount == 0 {
            return error("Test enrollment record not found or failed to update");
        }

        // Get updated record
        return check self.getTestEnrollmentByRecordId(recordId);
    }
}

// Global database connection instance
final TestEnrollmentDatabaseConnection testEnrollmentDbConnection = check new TestEnrollmentDatabaseConnection();
