import ballerina/sql;
import ballerinax/mysql;
import ashen/school_performance_panel.database_config;

// Database connection class for student course operations
public isolated class StudentCourseDatabaseConnection {
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

    // Validate that student exists and is not deleted
    public isolated function validateStudentExists(int studentId) returns boolean|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT student_id 
            FROM student 
            WHERE student_id = ${studentId} AND deleted_at IS NULL
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

    // Check if student is already enrolled in course
    public isolated function isStudentAlreadyEnrolled(int studentId, int courseId) returns boolean|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT record_id 
            FROM student_course 
            WHERE student_id = ${studentId} AND course_id = ${courseId}
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        record {|record {} value;|}? result = check resultStream.next();
        check resultStream.close();

        return result is record {};
    }

    // Add students to course (bulk insertion)
    public isolated function addStudentsToCourse(int courseId, int[] studentIds, int userId) returns StudentCourse[]|error {
        StudentCourse[] enrolledStudents = [];
        
        // Process each student individually
        foreach int studentId in studentIds {
            // Check if student is already enrolled
            boolean|error alreadyEnrolled = self.isStudentAlreadyEnrolled(studentId, courseId);
            
            if alreadyEnrolled is error {
                return error("Error checking enrollment status for student ID: " + studentId.toString());
            }
            
            if alreadyEnrolled {
                // Skip this student if already enrolled
                continue;
            }
            
            sql:ParameterizedQuery insertQuery = `
                INSERT INTO student_course (student_id, course_id, user_id) 
                VALUES (${studentId}, ${courseId}, ${userId})
            `;
            sql:ExecutionResult result = check self.dbClient->execute(insertQuery);

            if result.affectedRowCount == 0 {
                return error("Failed to enroll student ID: " + studentId.toString());
            }

            int|string? recordId = result.lastInsertId;
            if recordId is () {
                return error("Failed to get record ID for student ID: " + studentId.toString());
            }

            StudentCourse enrollment = {
                record_id: <int>recordId,
                student_id: studentId,
                course_id: courseId,
                user_id: userId
            };
            enrolledStudents.push(enrollment);
        }
        
        return enrolledStudents;
    }

    // Update student course record
    public isolated function updateStudentCourse(int recordId, int? studentId, int? courseId) returns StudentCourse|error {
        sql:ParameterizedQuery updateQuery;
        
        if studentId is int && courseId is int {
            // Validate both student and course exist
            boolean|error studentExists = self.validateStudentExists(studentId);
            boolean|error courseExists = self.validateCourseExists(courseId);
            
            if studentExists is error {
                return studentExists;
            }
            if courseExists is error {
                return courseExists;
            }
            if !studentExists {
                return error("Student not found or deleted");
            }
            if !courseExists {
                return error("Course not found or deleted");
            }
            
            // Check if this combination already exists (excluding current record)
            sql:ParameterizedQuery checkQuery = `
                SELECT record_id 
                FROM student_course 
                WHERE student_id = ${studentId} AND course_id = ${courseId} AND record_id != ${recordId}
            `;
            stream<record {}, error?> checkStream = self.dbClient->query(checkQuery);
            record {|record {} value;|}? duplicateCheck = check checkStream.next();
            check checkStream.close();
            
            if duplicateCheck is record {} {
                return error("Student is already enrolled in this course");
            }
            
            updateQuery = `UPDATE student_course SET student_id = ${studentId}, course_id = ${courseId}, updated_at = NOW() WHERE record_id = ${recordId}`;
        } else if studentId is int {
            // Validate student exists
            boolean|error studentExists = self.validateStudentExists(studentId);
            if studentExists is error {
                return studentExists;
            }
            if !studentExists {
                return error("Student not found or deleted");
            }
            
            updateQuery = `UPDATE student_course SET student_id = ${studentId}, updated_at = NOW() WHERE record_id = ${recordId}`;
        } else if courseId is int {
            // Validate course exists
            boolean|error courseExists = self.validateCourseExists(courseId);
            if courseExists is error {
                return courseExists;
            }
            if !courseExists {
                return error("Course not found or deleted");
            }
            
            updateQuery = `UPDATE student_course SET course_id = ${courseId}, updated_at = NOW() WHERE record_id = ${recordId}`;
        } else {
            return error("No fields to update");
        }

        sql:ExecutionResult result = check self.dbClient->execute(updateQuery);

        if result.affectedRowCount == 0 {
            return error("Student course record not found or failed to update");
        }

        // Get updated record
        return check self.getStudentCourseById(recordId);
    }

    // Delete student course record (hard delete)
    public isolated function deleteStudentCourse(int recordId) returns int|error {
        sql:ParameterizedQuery deleteQuery = `DELETE FROM student_course WHERE record_id = ${recordId}`;
        sql:ExecutionResult result = check self.dbClient->execute(deleteQuery);

        if result.affectedRowCount == 0 {
            return error("Student course record not found");
        }

        return recordId;
    }

    // Get student course by record ID
    public isolated function getStudentCourseById(int recordId) returns StudentCourse|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT record_id, student_id, course_id, user_id, created_at, updated_at
            FROM student_course 
            WHERE record_id = ${recordId}
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        record {|record {} value;|}? result = check resultStream.next();
        check resultStream.close();

        if result is () {
            return error("Student course record not found");
        }

        record {} recordData = result.value;
        
        return {
            record_id: <int>recordData["record_id"],
            student_id: <int>recordData["student_id"],
            course_id: <int>recordData["course_id"],
            user_id: <int>recordData["user_id"],
            created_at: recordData["created_at"].toString(),
            updated_at: recordData["updated_at"].toString()
        };
    }

    // Get all student courses by student ID
    public isolated function getStudentCoursesByStudentId(int studentId) returns StudentCourse[]|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT record_id, student_id, course_id, user_id, created_at, updated_at
            FROM student_course 
            WHERE student_id = ${studentId}
            ORDER BY created_at DESC
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        StudentCourse[] studentCourses = [];

        check from record {} recordData in resultStream
            do {
                StudentCourse studentCourse = {
                    record_id: <int>recordData["record_id"],
                    student_id: <int>recordData["student_id"],
                    course_id: <int>recordData["course_id"],
                    user_id: <int>recordData["user_id"],
                    created_at: recordData["created_at"].toString(),
                    updated_at: recordData["updated_at"].toString()
                };
                studentCourses.push(studentCourse);
            };

        return studentCourses;
    }

    // Get all student courses by course ID
    public isolated function getStudentCoursesByCourseId(int courseId) returns StudentCourse[]|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT record_id, student_id, course_id, user_id, created_at, updated_at
            FROM student_course 
            WHERE course_id = ${courseId}
            ORDER BY created_at DESC
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        StudentCourse[] studentCourses = [];

        check from record {} recordData in resultStream
            do {
                StudentCourse studentCourse = {
                    record_id: <int>recordData["record_id"],
                    student_id: <int>recordData["student_id"],
                    course_id: <int>recordData["course_id"],
                    user_id: <int>recordData["user_id"],
                    created_at: recordData["created_at"].toString(),
                    updated_at: recordData["updated_at"].toString()
                };
                studentCourses.push(studentCourse);
            };

        return studentCourses;
    }

    // Get student courses with details by student ID
    public isolated function getStudentCoursesWithDetailsByStudentId(int studentId) returns StudentCourseWithDetails[]|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT 
                sc.record_id,
                sc.student_id,
                s.full_name as student_name,
                sc.course_id,
                c.name as course_name,
                c.year as course_year,
                sc.user_id,
                sc.created_at,
                sc.updated_at
            FROM student_course sc
            JOIN student s ON sc.student_id = s.student_id AND s.deleted_at IS NULL
            JOIN course c ON sc.course_id = c.course_id AND c.deleted_at IS NULL
            WHERE sc.student_id = ${studentId}
            ORDER BY sc.created_at DESC
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        StudentCourseWithDetails[] studentCourses = [];

        check from record {} recordData in resultStream
            do {
                StudentCourseWithDetails studentCourse = {
                    record_id: <int>recordData["record_id"],
                    student_id: <int>recordData["student_id"],
                    student_name: <string>recordData["student_name"],
                    course_id: <int>recordData["course_id"],
                    course_name: <string>recordData["course_name"],
                    course_year: <string>recordData["course_year"],
                    user_id: <int>recordData["user_id"],
                    created_at: recordData["created_at"].toString(),
                    updated_at: recordData["updated_at"].toString()
                };
                studentCourses.push(studentCourse);
            };

        return studentCourses;
    }

    // Get student courses with details by course ID
    public isolated function getStudentCoursesWithDetailsByCourseId(int courseId) returns StudentCourseWithDetails[]|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT 
                sc.record_id,
                sc.student_id,
                s.full_name as student_name,
                sc.course_id,
                c.name as course_name,
                c.year as course_year,
                sc.user_id,
                sc.created_at,
                sc.updated_at
            FROM student_course sc
            JOIN student s ON sc.student_id = s.student_id AND s.deleted_at IS NULL
            JOIN course c ON sc.course_id = c.course_id AND c.deleted_at IS NULL
            WHERE sc.course_id = ${courseId}
            ORDER BY sc.created_at DESC
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        StudentCourseWithDetails[] studentCourses = [];

        check from record {} recordData in resultStream
            do {
                StudentCourseWithDetails studentCourse = {
                    record_id: <int>recordData["record_id"],
                    student_id: <int>recordData["student_id"],
                    student_name: <string>recordData["student_name"],
                    course_id: <int>recordData["course_id"],
                    course_name: <string>recordData["course_name"],
                    course_year: <string>recordData["course_year"],
                    user_id: <int>recordData["user_id"],
                    created_at: recordData["created_at"].toString(),
                    updated_at: recordData["updated_at"].toString()
                };
                studentCourses.push(studentCourse);
            };

        return studentCourses;
    }
}

// Global database connection instance
final StudentCourseDatabaseConnection studentCourseDbConnection = check new StudentCourseDatabaseConnection();
