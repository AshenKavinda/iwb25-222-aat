import ballerina/log;

// Function to add course subject enrollment with user validation
public isolated function addCourseSubjectEnrollment(AddCourseSubjectEnrollmentRequest addCourseSubjectEnrollmentReq) returns AddCourseSubjectEnrollmentResponse|ErrorResponse|error {
    // First validate that the user exists and is an officer
    boolean|error userValidation = courseSubjectEnrollmentDbConnection.validateUserIsOfficer(addCourseSubjectEnrollmentReq.user_id);
    
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
    boolean|error courseValidation = courseSubjectEnrollmentDbConnection.validateCourseExists(addCourseSubjectEnrollmentReq.course_id);
    
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

    // Validate that the subject exists
    boolean|error subjectValidation = courseSubjectEnrollmentDbConnection.validateSubjectExists(addCourseSubjectEnrollmentReq.subject_id);
    
    if subjectValidation is error {
        log:printError("Failed to validate subject", 'error = subjectValidation);
        return {
            message: subjectValidation.message(),
            'error: "SUBJECT_VALIDATION_ERROR"
        };
    }
    
    if subjectValidation is boolean && !subjectValidation {
        return {
            message: "Subject not found or deleted",
            'error: "INVALID_SUBJECT"
        };
    }

    // Validate that the teacher exists and has teacher role
    boolean|error teacherValidation = courseSubjectEnrollmentDbConnection.validateUserIsTeacher(addCourseSubjectEnrollmentReq.teacher_id);
    
    if teacherValidation is error {
        log:printError("Failed to validate teacher", 'error = teacherValidation);
        return {
            message: teacherValidation.message(),
            'error: "TEACHER_VALIDATION_ERROR"
        };
    }
    
    if teacherValidation is boolean && !teacherValidation {
        return {
            message: "Teacher ID does not exist or user is not a teacher",
            'error: "INVALID_TEACHER"
        };
    }

    CourseSubjectEnrollment|error result = courseSubjectEnrollmentDbConnection.addCourseSubjectEnrollment(
        addCourseSubjectEnrollmentReq.subject_id, 
        addCourseSubjectEnrollmentReq.course_id, 
        addCourseSubjectEnrollmentReq.teacher_id, 
        addCourseSubjectEnrollmentReq.user_id
    );

    if result is error {
        log:printError("Failed to add course subject enrollment", 'error = result);
        return {
            message: result.message(),
            'error: "ADD_COURSE_SUBJECT_ENROLLMENT_ERROR"
        };
    }

    return {
        message: "Course subject enrollment added successfully",
        data: result
    };
}

// Function to update course subject enrollment record (only subject_id field)
public isolated function updateCourseSubjectEnrollment(int recordId, UpdateCourseSubjectEnrollmentRequest updateCourseSubjectEnrollmentReq) returns UpdateCourseSubjectEnrollmentResponse|ErrorResponse|error {
    // Validate that the subject exists
    boolean|error subjectValidation = courseSubjectEnrollmentDbConnection.validateSubjectExists(updateCourseSubjectEnrollmentReq.subject_id);
    
    if subjectValidation is error {
        log:printError("Failed to validate subject", 'error = subjectValidation);
        return {
            message: subjectValidation.message(),
            'error: "SUBJECT_VALIDATION_ERROR"
        };
    }
    
    if subjectValidation is boolean && !subjectValidation {
        return {
            message: "Subject not found or deleted",
            'error: "INVALID_SUBJECT"
        };
    }

    CourseSubjectEnrollment|error result = courseSubjectEnrollmentDbConnection.updateCourseSubjectEnrollment(
        recordId, updateCourseSubjectEnrollmentReq.subject_id
    );

    if result is error {
        log:printError("Failed to update course subject enrollment record", 'error = result);
        return {
            message: result.message(),
            'error: "UPDATE_COURSE_SUBJECT_ENROLLMENT_ERROR"
        };
    }

    return {
        message: "Course subject enrollment record updated successfully",
        data: result
    };
}

// Function to delete course subject enrollment record (hard delete)
public isolated function deleteCourseSubjectEnrollment(int recordId) returns DeleteCourseSubjectEnrollmentResponse|ErrorResponse|error {
    int|error result = courseSubjectEnrollmentDbConnection.deleteCourseSubjectEnrollment(recordId);

    if result is error {
        log:printError("Failed to delete course subject enrollment record", 'error = result);
        return {
            message: result.message(),
            'error: "DELETE_ERROR"
        };
    }

    return {
        message: "Course subject enrollment record deleted successfully",
        record_id: result
    };
}

// Function to get all course subject enrollments by course ID
public isolated function getCourseSubjectEnrollmentsByCourseId(int courseId) returns GetCourseSubjectEnrollmentsByCourseIdResponse|ErrorResponse|error {
    // Validate that the course exists
    boolean|error courseValidation = courseSubjectEnrollmentDbConnection.validateCourseExists(courseId);
    
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

    CourseSubjectEnrollment[]|error result = courseSubjectEnrollmentDbConnection.getCourseSubjectEnrollmentsByCourseId(courseId);

    if result is error {
        log:printError("Failed to retrieve course subject enrollments", 'error = result);
        return {
            message: result.message(),
            'error: "FETCH_ERROR"
        };
    }

    return {
        message: "Course subject enrollments retrieved successfully",
        data: result
    };
}

// Function to get all course subject enrollments by teacher ID with course details
public isolated function getCourseSubjectEnrollmentsByTeacherId(int teacherId) returns GetCourseSubjectEnrollmentsByTeacherIdResponse|ErrorResponse|error {
    // Validate that the teacher exists and has teacher role
    boolean|error teacherValidation = courseSubjectEnrollmentDbConnection.validateUserIsTeacher(teacherId);
    
    if teacherValidation is error {
        log:printError("Failed to validate teacher", 'error = teacherValidation);
        return {
            message: teacherValidation.message(),
            'error: "TEACHER_VALIDATION_ERROR"
        };
    }
    
    if teacherValidation is boolean && !teacherValidation {
        return {
            message: "Teacher ID does not exist or user is not a teacher",
            'error: "INVALID_TEACHER"
        };
    }

    CourseSubjectEnrollmentWithDetails[]|error result = courseSubjectEnrollmentDbConnection.getCourseSubjectEnrollmentsByTeacherId(teacherId);

    if result is error {
        log:printError("Failed to retrieve course subject enrollments with details", 'error = result);
        return {
            message: result.message(),
            'error: "FETCH_ERROR"
        };
    }

    return {
        message: "Course subject enrollments with details retrieved successfully",
        data: result
    };
}
