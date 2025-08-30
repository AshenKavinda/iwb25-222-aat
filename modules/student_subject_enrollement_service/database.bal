import ballerina/sql;
import ballerinax/mysql;

// Database configuration
configurable string DB_HOST = "127.0.0.1";
configurable int DB_PORT = 3306;
configurable string DB_USERNAME = "root";
configurable string DB_PASSWORD = "Ashen#321";
configurable string DB_NAME = "school_performance";

// Database connection class for student subject enrollment operations
public isolated class StudentSubjectEnrollmentDatabaseConnection {
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

    // Check if student is enrolled in course
    public isolated function isStudentEnrolledInCourse(int studentId, int courseId) returns boolean|error {
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

    // Check if student is already enrolled in subject for course
    public isolated function isStudentAlreadyEnrolledInSubject(int studentId, int subjectId, int courseId) returns boolean|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT record_id 
            FROM student_subject_course 
            WHERE student_id = ${studentId} AND subject_id = ${subjectId} AND course_id = ${courseId}
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        record {|record {} value;|}? result = check resultStream.next();
        check resultStream.close();

        return result is record {};
    }

    // Get all students enrolled in a course
    public isolated function getStudentsInCourse(int courseId) returns int[]|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT student_id 
            FROM student_course 
            WHERE course_id = ${courseId}
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        int[] studentIds = [];

        check from record {} recordData in resultStream
            do {
                studentIds.push(<int>recordData["student_id"]);
            };

        return studentIds;
    }

    // Add common subjects to all students in course (individual insertions)
    public isolated function addCommonSubjectsToCourse(int courseId, int[] subjectIds, int userId) returns StudentSubjectEnrollment[]|error {
        // First get all students in the course
        int[]|error studentIds = self.getStudentsInCourse(courseId);
        
        if studentIds is error {
            return error("Failed to get students in course: " + studentIds.message());
        }

        if studentIds.length() == 0 {
            return error("No students found in the specified course");
        }

        StudentSubjectEnrollment[] enrollments = [];
        
        // Process each subject for each student individually
        foreach int subjectId in subjectIds {
            foreach int studentId in studentIds {
                // Check if student is already enrolled in this subject for this course
                boolean|error alreadyEnrolled = self.isStudentAlreadyEnrolledInSubject(studentId, subjectId, courseId);
                
                if alreadyEnrolled is error {
                    return error("Error checking enrollment status for student ID: " + studentId.toString() + " and subject ID: " + subjectId.toString());
                }
                
                if alreadyEnrolled {
                    // Skip this enrollment if already exists
                    continue;
                }
                
                sql:ParameterizedQuery insertQuery = `
                    INSERT INTO student_subject_course (student_id, subject_id, course_id, user_id) 
                    VALUES (${studentId}, ${subjectId}, ${courseId}, ${userId})
                `;
                sql:ExecutionResult result = check self.dbClient->execute(insertQuery);

                if result.affectedRowCount == 0 {
                    return error("Failed to enroll student ID: " + studentId.toString() + " in subject ID: " + subjectId.toString());
                }

                int|string? recordId = result.lastInsertId;
                if recordId is () {
                    return error("Failed to get record ID for student ID: " + studentId.toString() + " and subject ID: " + subjectId.toString());
                }

                StudentSubjectEnrollment enrollment = {
                    record_id: <int>recordId,
                    student_id: studentId,
                    subject_id: subjectId,
                    course_id: courseId,
                    user_id: userId
                };
                enrollments.push(enrollment);
            }
        }
        
        return enrollments;
    }

    // Add subjects to specific student (individual insertions)
    public isolated function addSubjectsToStudent(int studentId, int courseId, int[] subjectIds, int userId) returns StudentSubjectEnrollment[]|error {
        StudentSubjectEnrollment[] enrollments = [];
        
        // Process each subject individually
        foreach int subjectId in subjectIds {
            // Check if student is already enrolled in this subject for this course
            boolean|error alreadyEnrolled = self.isStudentAlreadyEnrolledInSubject(studentId, subjectId, courseId);
            
            if alreadyEnrolled is error {
                return error("Error checking enrollment status for subject ID: " + subjectId.toString());
            }
            
            if alreadyEnrolled {
                // Skip this subject if already enrolled
                continue;
            }
            
            sql:ParameterizedQuery insertQuery = `
                INSERT INTO student_subject_course (student_id, subject_id, course_id, user_id) 
                VALUES (${studentId}, ${subjectId}, ${courseId}, ${userId})
            `;
            sql:ExecutionResult result = check self.dbClient->execute(insertQuery);

            if result.affectedRowCount == 0 {
                return error("Failed to enroll student in subject ID: " + subjectId.toString());
            }

            int|string? recordId = result.lastInsertId;
            if recordId is () {
                return error("Failed to get record ID for subject ID: " + subjectId.toString());
            }

            StudentSubjectEnrollment enrollment = {
                record_id: <int>recordId,
                student_id: studentId,
                subject_id: subjectId,
                course_id: courseId,
                user_id: userId
            };
            enrollments.push(enrollment);
        }
        
        return enrollments;
    }

    // Update student subject enrollment record
    public isolated function updateStudentSubjectEnrollment(int recordId, int? studentId, int? subjectId, int? courseId) returns StudentSubjectEnrollment|error {
        sql:ParameterizedQuery updateQuery;
        
        if studentId is int && subjectId is int && courseId is int {
            // Validate all entities exist
            boolean|error studentExists = self.validateStudentExists(studentId);
            boolean|error subjectExists = self.validateSubjectExists(subjectId);
            boolean|error courseExists = self.validateCourseExists(courseId);
            
            if studentExists is error {
                return studentExists;
            }
            if subjectExists is error {
                return subjectExists;
            }
            if courseExists is error {
                return courseExists;
            }
            if !studentExists {
                return error("Student not found or deleted");
            }
            if !subjectExists {
                return error("Subject not found or deleted");
            }
            if !courseExists {
                return error("Course not found or deleted");
            }
            
            // Check if student is enrolled in the course
            boolean|error enrolledInCourse = self.isStudentEnrolledInCourse(studentId, courseId);
            if enrolledInCourse is error {
                return enrolledInCourse;
            }
            if !enrolledInCourse {
                return error("Student is not enrolled in the specified course");
            }
            
            // Check if this combination already exists (excluding current record)
            sql:ParameterizedQuery checkQuery = `
                SELECT record_id 
                FROM student_subject_course 
                WHERE student_id = ${studentId} AND subject_id = ${subjectId} AND course_id = ${courseId} AND record_id != ${recordId}
            `;
            stream<record {}, error?> checkStream = self.dbClient->query(checkQuery);
            record {|record {} value;|}? duplicateCheck = check checkStream.next();
            check checkStream.close();
            
            if duplicateCheck is record {} {
                return error("Student is already enrolled in this subject for this course");
            }
            
            updateQuery = `UPDATE student_subject_course SET student_id = ${studentId}, subject_id = ${subjectId}, course_id = ${courseId}, updated_at = NOW() WHERE record_id = ${recordId}`;
        } else if studentId is int && subjectId is int {
            // Validate student and subject exist
            boolean|error studentExists = self.validateStudentExists(studentId);
            boolean|error subjectExists = self.validateSubjectExists(subjectId);
            
            if studentExists is error {
                return studentExists;
            }
            if subjectExists is error {
                return subjectExists;
            }
            if !studentExists {
                return error("Student not found or deleted");
            }
            if !subjectExists {
                return error("Subject not found or deleted");
            }
            
            updateQuery = `UPDATE student_subject_course SET student_id = ${studentId}, subject_id = ${subjectId}, updated_at = NOW() WHERE record_id = ${recordId}`;
        } else if studentId is int && courseId is int {
            // Validate student and course exist
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
            
            // Check if student is enrolled in the course
            boolean|error enrolledInCourse = self.isStudentEnrolledInCourse(studentId, courseId);
            if enrolledInCourse is error {
                return enrolledInCourse;
            }
            if !enrolledInCourse {
                return error("Student is not enrolled in the specified course");
            }
            
            updateQuery = `UPDATE student_subject_course SET student_id = ${studentId}, course_id = ${courseId}, updated_at = NOW() WHERE record_id = ${recordId}`;
        } else if subjectId is int && courseId is int {
            // Validate subject and course exist
            boolean|error subjectExists = self.validateSubjectExists(subjectId);
            boolean|error courseExists = self.validateCourseExists(courseId);
            
            if subjectExists is error {
                return subjectExists;
            }
            if courseExists is error {
                return courseExists;
            }
            if !subjectExists {
                return error("Subject not found or deleted");
            }
            if !courseExists {
                return error("Course not found or deleted");
            }
            
            updateQuery = `UPDATE student_subject_course SET subject_id = ${subjectId}, course_id = ${courseId}, updated_at = NOW() WHERE record_id = ${recordId}`;
        } else if studentId is int {
            // Validate student exists
            boolean|error studentExists = self.validateStudentExists(studentId);
            if studentExists is error {
                return studentExists;
            }
            if !studentExists {
                return error("Student not found or deleted");
            }
            
            updateQuery = `UPDATE student_subject_course SET student_id = ${studentId}, updated_at = NOW() WHERE record_id = ${recordId}`;
        } else if subjectId is int {
            // Validate subject exists
            boolean|error subjectExists = self.validateSubjectExists(subjectId);
            if subjectExists is error {
                return subjectExists;
            }
            if !subjectExists {
                return error("Subject not found or deleted");
            }
            
            updateQuery = `UPDATE student_subject_course SET subject_id = ${subjectId}, updated_at = NOW() WHERE record_id = ${recordId}`;
        } else if courseId is int {
            // Validate course exists
            boolean|error courseExists = self.validateCourseExists(courseId);
            if courseExists is error {
                return courseExists;
            }
            if !courseExists {
                return error("Course not found or deleted");
            }
            
            updateQuery = `UPDATE student_subject_course SET course_id = ${courseId}, updated_at = NOW() WHERE record_id = ${recordId}`;
        } else {
            return error("No fields to update");
        }

        sql:ExecutionResult result = check self.dbClient->execute(updateQuery);

        if result.affectedRowCount == 0 {
            return error("Student subject enrollment record not found or failed to update");
        }

        // Get updated record
        return check self.getStudentSubjectEnrollmentById(recordId);
    }

    // Delete student subject enrollment record (hard delete)
    public isolated function deleteStudentSubjectEnrollment(int recordId) returns int|error {
        sql:ParameterizedQuery deleteQuery = `DELETE FROM student_subject_course WHERE record_id = ${recordId}`;
        sql:ExecutionResult result = check self.dbClient->execute(deleteQuery);

        if result.affectedRowCount == 0 {
            return error("Student subject enrollment record not found");
        }

        return recordId;
    }

    // Get student subject enrollment by record ID
    public isolated function getStudentSubjectEnrollmentById(int recordId) returns StudentSubjectEnrollment|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT record_id, student_id, subject_id, course_id, user_id, created_at, updated_at
            FROM student_subject_course 
            WHERE record_id = ${recordId}
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        record {|record {} value;|}? result = check resultStream.next();
        check resultStream.close();

        if result is () {
            return error("Student subject enrollment record not found");
        }

        record {} recordData = result.value;
        
        return {
            record_id: <int>recordData["record_id"],
            student_id: <int>recordData["student_id"],
            subject_id: <int>recordData["subject_id"],
            course_id: <int>recordData["course_id"],
            user_id: <int>recordData["user_id"],
            created_at: recordData["created_at"].toString(),
            updated_at: recordData["updated_at"].toString()
        };
    }

    // Get student subject enrollments with details by student ID and course ID
    public isolated function getStudentSubjectEnrollmentsWithDetails(int studentId, int courseId) returns StudentSubjectEnrollmentWithDetails[]|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT 
                ssc.record_id,
                ssc.student_id,
                s.full_name as student_name,
                ssc.subject_id,
                sub.name as subject_name,
                sub.weight as subject_weight,
                ssc.course_id,
                c.name as course_name,
                c.year as course_year,
                ssc.user_id,
                ssc.created_at,
                ssc.updated_at
            FROM student_subject_course ssc
            JOIN student s ON ssc.student_id = s.student_id AND s.deleted_at IS NULL
            JOIN subject sub ON ssc.subject_id = sub.subject_id AND sub.deleted_at IS NULL
            JOIN course c ON ssc.course_id = c.course_id AND c.deleted_at IS NULL
            WHERE ssc.student_id = ${studentId} AND ssc.course_id = ${courseId}
            ORDER BY ssc.created_at DESC
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        StudentSubjectEnrollmentWithDetails[] enrollments = [];

        check from record {} recordData in resultStream
            do {
                StudentSubjectEnrollmentWithDetails enrollment = {
                    record_id: <int>recordData["record_id"],
                    student_id: <int>recordData["student_id"],
                    student_name: <string>recordData["student_name"],
                    subject_id: <int>recordData["subject_id"],
                    subject_name: <string>recordData["subject_name"],
                    subject_weight: recordData["subject_weight"] is () ? () : <decimal>recordData["subject_weight"],
                    course_id: <int>recordData["course_id"],
                    course_name: <string>recordData["course_name"],
                    course_year: <string>recordData["course_year"],
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
final StudentSubjectEnrollmentDatabaseConnection studentSubjectEnrollmentDbConnection = check new StudentSubjectEnrollmentDatabaseConnection();
