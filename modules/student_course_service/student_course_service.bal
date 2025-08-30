import ballerina/log;

// Function to add students to course (bulk insertion) with user validation
public isolated function addStudentsToCourse(AddStudentsToCourseRequest addStudentsToCourseReq) returns AddStudentsToCourseResponse|ErrorResponse|error {
    // First validate that the user exists and is an officer
    boolean|error userValidation = studentCourseDbConnection.validateUserIsOfficer(addStudentsToCourseReq.user_id);
    
    if userValidation is error {
        log:printError("Failed to validate user", 'error = userValidation);
        return {
            message: userValidation.message(),
            'error: "USER_VALIDATION_ERROR"
        };
    }
    
    if userValidation is boolean && !userValidation {
        return {
            message: "User ID does not exist or user is not an officer",
            'error: "INVALID_USER_OR_ROLE"
        };
    }

    // Validate that the course exists
    boolean|error courseValidation = studentCourseDbConnection.validateCourseExists(addStudentsToCourseReq.course_id);
    
    if courseValidation is error {
        log:printError("Failed to validate course", 'error = courseValidation);
        return {
            message: courseValidation.message(),
            'error: "COURSE_VALIDATION_ERROR"
        };
    }
    
    if courseValidation is boolean && !courseValidation {
        return {
            message: "Course not found or deleted",
            'error: "INVALID_COURSE"
        };
    }

    // Validate that all students exist
    foreach int studentId in addStudentsToCourseReq.student_ids {
        boolean|error studentValidation = studentCourseDbConnection.validateStudentExists(studentId);
        
        if studentValidation is error {
            log:printError("Failed to validate student", 'error = studentValidation);
            return {
                message: studentValidation.message(),
                'error: "STUDENT_VALIDATION_ERROR"
            };
        }
        
        if studentValidation is boolean && !studentValidation {
            return {
                message: "Student ID " + studentId.toString() + " not found or deleted",
                'error: "INVALID_STUDENT"
            };
        }
    }

    StudentCourse[]|error result = studentCourseDbConnection.addStudentsToCourse(
        addStudentsToCourseReq.course_id, addStudentsToCourseReq.student_ids, addStudentsToCourseReq.user_id
    );

    if result is error {
        log:printError("Failed to add students to course", 'error = result);
        return {
            message: result.message(),
            'error: "ADD_STUDENTS_TO_COURSE_ERROR"
        };
    }

    return {
        message: "Students added to course successfully",
        data: result
    };
}

// Function to update student course record
public isolated function updateStudentCourse(int recordId, UpdateStudentCourseRequest updateStudentCourseReq) returns UpdateStudentCourseResponse|ErrorResponse|error {
    StudentCourse|error result = studentCourseDbConnection.updateStudentCourse(
        recordId, updateStudentCourseReq?.student_id, updateStudentCourseReq?.course_id
    );

    if result is error {
        log:printError("Failed to update student course record", 'error = result);
        return {
            message: result.message(),
            'error: "UPDATE_STUDENT_COURSE_ERROR"
        };
    }

    return {
        message: "Student course record updated successfully",
        data: result
    };
}

// Function to delete student course record (hard delete)
public isolated function deleteStudentCourse(int recordId) returns DeleteStudentCourseResponse|ErrorResponse|error {
    int|error result = studentCourseDbConnection.deleteStudentCourse(recordId);

    if result is error {
        log:printError("Failed to delete student course record", 'error = result);
        return {
            message: result.message(),
            'error: "DELETE_ERROR"
        };
    }

    return {
        message: "Student course record deleted successfully",
        record_id: result
    };
}

// Function to get student course by record ID
public isolated function getStudentCourseById(int recordId) returns GetStudentCourseByIdResponse|ErrorResponse|error {
    StudentCourse|error result = studentCourseDbConnection.getStudentCourseById(recordId);

    if result is error {
        log:printError("Failed to retrieve student course record", 'error = result);
        return {
            message: result.message(),
            'error: "RECORD_NOT_FOUND"
        };
    }

    return {
        message: "Student course record retrieved successfully",
        data: result
    };
}

// Function to get all student courses by student ID
public isolated function getStudentCoursesByStudentId(int studentId) returns GetStudentCoursesByStudentIdResponse|ErrorResponse|error {
    // Validate that the student exists
    boolean|error studentValidation = studentCourseDbConnection.validateStudentExists(studentId);
    
    if studentValidation is error {
        log:printError("Failed to validate student", 'error = studentValidation);
        return {
            message: studentValidation.message(),
            'error: "STUDENT_VALIDATION_ERROR"
        };
    }
    
    if studentValidation is boolean && !studentValidation {
        return {
            message: "Student not found or deleted",
            'error: "INVALID_STUDENT"
        };
    }

    StudentCourse[]|error result = studentCourseDbConnection.getStudentCoursesByStudentId(studentId);

    if result is error {
        log:printError("Failed to retrieve student courses", 'error = result);
        return {
            message: result.message(),
            'error: "FETCH_ERROR"
        };
    }

    return {
        message: "Student courses retrieved successfully",
        data: result
    };
}

// Function to get all student courses by course ID
public isolated function getStudentCoursesByCourseId(int courseId) returns GetStudentCoursesByCourseIdResponse|ErrorResponse|error {
    // Validate that the course exists
    boolean|error courseValidation = studentCourseDbConnection.validateCourseExists(courseId);
    
    if courseValidation is error {
        log:printError("Failed to validate course", 'error = courseValidation);
        return {
            message: courseValidation.message(),
            'error: "COURSE_VALIDATION_ERROR"
        };
    }
    
    if courseValidation is boolean && !courseValidation {
        return {
            message: "Course not found or deleted",
            'error: "INVALID_COURSE"
        };
    }

    StudentCourse[]|error result = studentCourseDbConnection.getStudentCoursesByCourseId(courseId);

    if result is error {
        log:printError("Failed to retrieve student courses", 'error = result);
        return {
            message: result.message(),
            'error: "FETCH_ERROR"
        };
    }

    return {
        message: "Student courses retrieved successfully",
        data: result
    };
}

// Function to get student courses with details by student ID
public isolated function getStudentCoursesWithDetailsByStudentId(int studentId) returns GetStudentCoursesWithDetailsResponse|ErrorResponse|error {
    // Validate that the student exists
    boolean|error studentValidation = studentCourseDbConnection.validateStudentExists(studentId);
    
    if studentValidation is error {
        log:printError("Failed to validate student", 'error = studentValidation);
        return {
            message: studentValidation.message(),
            'error: "STUDENT_VALIDATION_ERROR"
        };
    }
    
    if studentValidation is boolean && !studentValidation {
        return {
            message: "Student not found or deleted",
            'error: "INVALID_STUDENT"
        };
    }

    StudentCourseWithDetails[]|error result = studentCourseDbConnection.getStudentCoursesWithDetailsByStudentId(studentId);

    if result is error {
        log:printError("Failed to retrieve student courses with details", 'error = result);
        return {
            message: result.message(),
            'error: "FETCH_ERROR"
        };
    }

    return {
        message: "Student courses with details retrieved successfully",
        data: result
    };
}

// Function to get student courses with details by course ID
public isolated function getStudentCoursesWithDetailsByCourseId(int courseId) returns GetStudentCoursesWithDetailsResponse|ErrorResponse|error {
    // Validate that the course exists
    boolean|error courseValidation = studentCourseDbConnection.validateCourseExists(courseId);
    
    if courseValidation is error {
        log:printError("Failed to validate course", 'error = courseValidation);
        return {
            message: courseValidation.message(),
            'error: "COURSE_VALIDATION_ERROR"
        };
    }
    
    if courseValidation is boolean && !courseValidation {
        return {
            message: "Course not found or deleted",
            'error: "INVALID_COURSE"
        };
    }

    StudentCourseWithDetails[]|error result = studentCourseDbConnection.getStudentCoursesWithDetailsByCourseId(courseId);

    if result is error {
        log:printError("Failed to retrieve student courses with details", 'error = result);
        return {
            message: result.message(),
            'error: "FETCH_ERROR"
        };
    }

    return {
        message: "Student courses with details retrieved successfully",
        data: result
    };
}
