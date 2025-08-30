import ballerina/log;

// Function to get top performing students
public isolated function getTopPerformingStudents(string year, string termType, int? limitCount) returns TopPerformingStudentsResponse|ErrorResponse|error {
    int actualLimit = limitCount ?: 10; // Default to top 10 if not specified
    
    TopPerformingStudent[]|error result = reportDbConnection.getTopPerformingStudents(year, termType, actualLimit);

    if result is error {
        log:printError("Failed to retrieve top performing students", 'error = result);
        return {
            message: result.message(),
            'error: "FETCH_ERROR"
        };
    }

    return {
        message: "Top performing students retrieved successfully",
        data: result
    };
}

// Function to get average marks per subject by course and term
public isolated function getAverageMarksBySubject(string year, string termType) returns AverageMarksBySubjectResponse|ErrorResponse|error {
    AverageMarksBySubject[]|error result = reportDbConnection.getAverageMarksBySubject(year, termType);

    if result is error {
        log:printError("Failed to retrieve average marks by subject", 'error = result);
        return {
            message: result.message(),
            'error: "FETCH_ERROR"
        };
    }

    return {
        message: "Average marks by subject retrieved successfully",
        data: result
    };
}

// Function to get teacher performance report
public isolated function getTeacherPerformance() returns TeacherPerformanceResponse|ErrorResponse|error {
    TeacherPerformance[]|error result = reportDbConnection.getTeacherPerformance();

    if result is error {
        log:printError("Failed to retrieve teacher performance", 'error = result);
        return {
            message: result.message(),
            'error: "FETCH_ERROR"
        };
    }

    return {
        message: "Teacher performance report retrieved successfully",
        data: result
    };
}

// Function to get student progress across terms
public isolated function getStudentProgress(string year) returns StudentProgressResponse|ErrorResponse|error {
    StudentProgress[]|error result = reportDbConnection.getStudentProgress(year);

    if result is error {
        log:printError("Failed to retrieve student progress", 'error = result);
        return {
            message: result.message(),
            'error: "FETCH_ERROR"
        };
    }

    return {
        message: "Student progress report retrieved successfully",
        data: result
    };
}

// Function to get low performing subjects
public isolated function getLowPerformingSubjects(string year, decimal? threshold) returns LowPerformingSubjectsResponse|ErrorResponse|error {
    decimal thresholdValue = threshold ?: 40.0; // Default threshold is 40
    
    LowPerformingSubject[]|error result = reportDbConnection.getLowPerformingSubjects(year, thresholdValue);

    if result is error {
        log:printError("Failed to retrieve low performing subjects", 'error = result);
        return {
            message: result.message(),
            'error: "FETCH_ERROR"
        };
    }

    return {
        message: "Low performing subjects retrieved successfully",
        data: result
    };
}

// Function to get top performing courses
public isolated function getTopPerformingCourses(string year, string termType) returns TopPerformingCoursesResponse|ErrorResponse|error {
    TopPerformingCourse[]|error result = reportDbConnection.getTopPerformingCourses(year, termType);

    if result is error {
        log:printError("Failed to retrieve top performing courses", 'error = result);
        return {
            message: result.message(),
            'error: "FETCH_ERROR"
        };
    }

    return {
        message: "Top performing courses retrieved successfully",
        data: result
    };
}
