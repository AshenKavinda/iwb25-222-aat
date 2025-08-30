import ballerina/sql;
import ballerinax/mysql;
import ashen/school_performance_panel.database_config;

// Database connection class for course operations
public isolated class CourseDatabaseConnection {
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

    // Validate that course exists and belongs to a valid officer
    public isolated function validateCourseBelongsToOfficer(int courseId) returns boolean|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT u.role 
            FROM course c 
            JOIN user u ON c.user_id = u.user_id 
            WHERE c.course_id = ${courseId} AND c.deleted_at IS NULL AND u.deleted_at IS NULL
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        record {|record {} value;|}? result = check resultStream.next();
        check resultStream.close();

        if result is () {
            return error("Course not found or associated user is deleted");
        }

        record {} userData = result.value;
        string userRole = <string>userData["role"];
        
        return userRole == "officer";
    }

    // Validate that deleted course exists and belongs to a valid officer
    public isolated function validateDeletedCourseBelongsToOfficer(int courseId) returns boolean|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT u.role 
            FROM course c 
            JOIN user u ON c.user_id = u.user_id 
            WHERE c.course_id = ${courseId} AND c.deleted_at IS NOT NULL AND u.deleted_at IS NULL
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        record {|record {} value;|}? result = check resultStream.next();
        check resultStream.close();

        if result is () {
            return error("Deleted course not found or associated user is deleted");
        }

        record {} userData = result.value;
        string userRole = <string>userData["role"];
        
        return userRole == "officer";
    }

    // Add course
    public isolated function addCourse(string name, string? hall, string year, int userId) returns Course|error {
        sql:ParameterizedQuery insertQuery = `
            INSERT INTO course (name, hall, year, user_id) 
            VALUES (${name}, ${hall}, ${year}, ${userId})
        `;
        sql:ExecutionResult result = check self.dbClient->execute(insertQuery);

        if result.affectedRowCount == 0 {
            return error("Failed to create course");
        }

        int|string? courseId = result.lastInsertId;
        if courseId is () {
            return error("Failed to get course ID");
        }

        return {
            course_id: <int>courseId,
            name: name,
            hall: hall,
            year: year,
            user_id: userId
        };
    }

    // Update course
    public isolated function updateCourse(int courseId, string? name, string? hall, string? year) returns Course|error {
        sql:ParameterizedQuery updateQuery;
        
        if name is string && hall is string && year is string {
            updateQuery = `UPDATE course SET name = ${name}, hall = ${hall}, year = ${year}, updated_at = NOW() WHERE course_id = ${courseId} AND deleted_at IS NULL`;
        } else if name is string && hall is string {
            updateQuery = `UPDATE course SET name = ${name}, hall = ${hall}, updated_at = NOW() WHERE course_id = ${courseId} AND deleted_at IS NULL`;
        } else if name is string && year is string {
            updateQuery = `UPDATE course SET name = ${name}, year = ${year}, updated_at = NOW() WHERE course_id = ${courseId} AND deleted_at IS NULL`;
        } else if hall is string && year is string {
            updateQuery = `UPDATE course SET hall = ${hall}, year = ${year}, updated_at = NOW() WHERE course_id = ${courseId} AND deleted_at IS NULL`;
        } else if name is string {
            updateQuery = `UPDATE course SET name = ${name}, updated_at = NOW() WHERE course_id = ${courseId} AND deleted_at IS NULL`;
        } else if hall is string {
            updateQuery = `UPDATE course SET hall = ${hall}, updated_at = NOW() WHERE course_id = ${courseId} AND deleted_at IS NULL`;
        } else if year is string {
            updateQuery = `UPDATE course SET year = ${year}, updated_at = NOW() WHERE course_id = ${courseId} AND deleted_at IS NULL`;
        } else {
            return error("No fields to update");
        }

        sql:ExecutionResult result = check self.dbClient->execute(updateQuery);

        if result.affectedRowCount == 0 {
            return error("Course not found or failed to update");
        }

        // Get updated course
        return check self.getCourseById(courseId);
    }

    // Soft delete course
    public isolated function softDeleteCourse(int courseId) returns int|error {
        sql:ParameterizedQuery updateQuery = `UPDATE course SET deleted_at = NOW() WHERE course_id = ${courseId} AND deleted_at IS NULL`;
        sql:ExecutionResult result = check self.dbClient->execute(updateQuery);

        if result.affectedRowCount == 0 {
            return error("Course not found or already deleted");
        }

        return courseId;
    }

    // Restore soft deleted course
    public isolated function restoreCourse(int courseId) returns Course|error {
        sql:ParameterizedQuery updateQuery = `UPDATE course SET deleted_at = NULL WHERE course_id = ${courseId} AND deleted_at IS NOT NULL`;
        sql:ExecutionResult result = check self.dbClient->execute(updateQuery);

        if result.affectedRowCount == 0 {
            return error("Course not found or not deleted");
        }

        // Get restored course
        return check self.getCourseById(courseId);
    }

    // Get all active courses
    public isolated function getAllCourses() returns Course[]|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT course_id, name, hall, year, user_id, created_at, updated_at, deleted_at
            FROM course 
            WHERE deleted_at IS NULL
            ORDER BY created_at DESC
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        Course[] courses = [];

        check from record {} courseData in resultStream
            do {
                Course course = {
                    course_id: <int>courseData["course_id"],
                    name: <string>courseData["name"],
                    hall: courseData["hall"] is () ? () : <string>courseData["hall"],
                    year: <string>courseData["year"],
                    user_id: <int>courseData["user_id"],
                    created_at: courseData["created_at"].toString(),
                    updated_at: courseData["updated_at"].toString(),
                    deleted_at: courseData["deleted_at"] is () ? () : courseData["deleted_at"].toString()
                };
                courses.push(course);
            };

        return courses;
    }

    // Get course by ID
    public isolated function getCourseById(int courseId) returns Course|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT course_id, name, hall, year, user_id, created_at, updated_at, deleted_at
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
        
        return {
            course_id: <int>courseData["course_id"],
            name: <string>courseData["name"],
            hall: courseData["hall"] is () ? () : <string>courseData["hall"],
            year: <string>courseData["year"],
            user_id: <int>courseData["user_id"],
            created_at: courseData["created_at"].toString(),
            updated_at: courseData["updated_at"].toString(),
            deleted_at: courseData["deleted_at"] is () ? () : courseData["deleted_at"].toString()
        };
    }

    // Get all deleted courses
    public isolated function getDeletedCourses() returns Course[]|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT course_id, name, hall, year, user_id, created_at, updated_at, deleted_at
            FROM course 
            WHERE deleted_at IS NOT NULL
            ORDER BY deleted_at DESC
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        Course[] courses = [];

        check from record {} courseData in resultStream
            do {
                Course course = {
                    course_id: <int>courseData["course_id"],
                    name: <string>courseData["name"],
                    hall: courseData["hall"] is () ? () : <string>courseData["hall"],
                    year: <string>courseData["year"],
                    user_id: <int>courseData["user_id"],
                    created_at: courseData["created_at"].toString(),
                    updated_at: courseData["updated_at"].toString(),
                    deleted_at: courseData["deleted_at"] is () ? () : courseData["deleted_at"].toString()
                };
                courses.push(course);
            };

        return courses;
    }

    // Get all available years
    public isolated function getAvailableYears() returns string[]|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT DISTINCT year 
            FROM course 
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

    // Search courses by name and year
    public isolated function searchCoursesByNameAndYear(string? namePattern, string? year) returns Course[]|error {
        sql:ParameterizedQuery selectQuery;
        
        if namePattern is string && year is string {
            selectQuery = `
                SELECT course_id, name, hall, year, user_id, created_at, updated_at, deleted_at
                FROM course 
                WHERE name LIKE ${namePattern} AND year = ${year} AND deleted_at IS NULL
                ORDER BY created_at DESC
            `;
        } else if namePattern is string {
            selectQuery = `
                SELECT course_id, name, hall, year, user_id, created_at, updated_at, deleted_at
                FROM course 
                WHERE name LIKE ${namePattern} AND deleted_at IS NULL
                ORDER BY created_at DESC
            `;
        } else if year is string {
            selectQuery = `
                SELECT course_id, name, hall, year, user_id, created_at, updated_at, deleted_at
                FROM course 
                WHERE year = ${year} AND deleted_at IS NULL
                ORDER BY created_at DESC
            `;
        } else {
            return error("At least one search parameter (name or year) must be provided");
        }
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        Course[] courses = [];

        check from record {} courseData in resultStream
            do {
                Course course = {
                    course_id: <int>courseData["course_id"],
                    name: <string>courseData["name"],
                    hall: courseData["hall"] is () ? () : <string>courseData["hall"],
                    year: <string>courseData["year"],
                    user_id: <int>courseData["user_id"],
                    created_at: courseData["created_at"].toString(),
                    updated_at: courseData["updated_at"].toString(),
                    deleted_at: courseData["deleted_at"] is () ? () : courseData["deleted_at"].toString()
                };
                courses.push(course);
            };

        return courses;
    }
}

// Global database connection instance
final CourseDatabaseConnection courseDbConnection = check new CourseDatabaseConnection();
