import ballerina/log;

// Function to add common subjects to all students in a course with user validation
public isolated function addCommonSubjectsToCourse(AddCommonSubjectsRequest addCommonSubjectsReq) returns AddCommonSubjectsResponse|ErrorResponse|error {
    // First validate that the user exists and is an officer
    boolean|error userValidation = studentSubjectEnrollmentDbConnection.validateUserIsOfficer(addCommonSubjectsReq.user_id);
    
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
    boolean|error courseValidation = studentSubjectEnrollmentDbConnection.validateCourseExists(addCommonSubjectsReq.course_id);
    
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

    // Validate that all subjects exist
    foreach int subjectId in addCommonSubjectsReq.subject_ids {
        boolean|error subjectValidation = studentSubjectEnrollmentDbConnection.validateSubjectExists(subjectId);
        
        if subjectValidation is error {
            log:printError("Failed to validate subject", 'error = subjectValidation);
            return {
                message: subjectValidation.message(),
                'error: "SUBJECT_VALIDATION_ERROR"
            };
        }
        
        if subjectValidation is boolean && !subjectValidation {
            return {
                message: "Subject ID " + subjectId.toString() + " not found or deleted",
                'error: "INVALID_SUBJECT"
            };
        }
    }

    StudentSubjectEnrollment[]|error result = studentSubjectEnrollmentDbConnection.addCommonSubjectsToCourse(
        addCommonSubjectsReq.course_id, addCommonSubjectsReq.subject_ids, addCommonSubjectsReq.user_id
    );

    if result is error {
        log:printError("Failed to add common subjects to course", 'error = result);
        return {
            message: result.message(),
            'error: "ADD_COMMON_SUBJECTS_ERROR"
        };
    }

    return {
        message: "Common subjects added to course successfully",
        data: result
    };
}

// Function to add subjects to a specific student with validation
public isolated function addSubjectsToStudent(AddSubjectsToStudentRequest addSubjectsToStudentReq) returns AddSubjectsToStudentResponse|ErrorResponse|error {
    // First validate that the user exists and is an officer
    boolean|error userValidation = studentSubjectEnrollmentDbConnection.validateUserIsOfficer(addSubjectsToStudentReq.user_id);
    
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

    // Validate that the student exists
    boolean|error studentValidation = studentSubjectEnrollmentDbConnection.validateStudentExists(addSubjectsToStudentReq.student_id);
    
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

    // Validate that the course exists
    boolean|error courseValidation = studentSubjectEnrollmentDbConnection.validateCourseExists(addSubjectsToStudentReq.course_id);
    
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

    // Validate that student is enrolled in the course
    boolean|error enrollmentValidation = studentSubjectEnrollmentDbConnection.isStudentEnrolledInCourse(addSubjectsToStudentReq.student_id, addSubjectsToStudentReq.course_id);
    
    if enrollmentValidation is error {
        log:printError("Failed to validate student course enrollment", 'error = enrollmentValidation);
        return {
            message: enrollmentValidation.message(),
            'error: "ENROLLMENT_VALIDATION_ERROR"
        };
    }
    
    if enrollmentValidation is boolean && !enrollmentValidation {
        return {
            message: "Student is not enrolled in the specified course",
            'error: "STUDENT_NOT_ENROLLED_IN_COURSE"
        };
    }

    // Validate that all subjects exist
    foreach int subjectId in addSubjectsToStudentReq.subject_ids {
        boolean|error subjectValidation = studentSubjectEnrollmentDbConnection.validateSubjectExists(subjectId);
        
        if subjectValidation is error {
            log:printError("Failed to validate subject", 'error = subjectValidation);
            return {
                message: subjectValidation.message(),
                'error: "SUBJECT_VALIDATION_ERROR"
            };
        }
        
        if subjectValidation is boolean && !subjectValidation {
            return {
                message: "Subject ID " + subjectId.toString() + " not found or deleted",
                'error: "INVALID_SUBJECT"
            };
        }
    }

    StudentSubjectEnrollment[]|error result = studentSubjectEnrollmentDbConnection.addSubjectsToStudent(
        addSubjectsToStudentReq.student_id, addSubjectsToStudentReq.course_id, addSubjectsToStudentReq.subject_ids, addSubjectsToStudentReq.user_id
    );

    if result is error {
        log:printError("Failed to add subjects to student", 'error = result);
        return {
            message: result.message(),
            'error: "ADD_SUBJECTS_TO_STUDENT_ERROR"
        };
    }

    return {
        message: "Subjects added to student successfully",
        data: result
    };
}

// Function to update student subject enrollment record
public isolated function updateStudentSubjectEnrollment(int recordId, UpdateStudentSubjectEnrollmentRequest updateStudentSubjectEnrollmentReq) returns UpdateStudentSubjectEnrollmentResponse|ErrorResponse|error {
    StudentSubjectEnrollment|error result = studentSubjectEnrollmentDbConnection.updateStudentSubjectEnrollment(
        recordId, updateStudentSubjectEnrollmentReq?.student_id, updateStudentSubjectEnrollmentReq?.subject_id, updateStudentSubjectEnrollmentReq?.course_id
    );

    if result is error {
        log:printError("Failed to update student subject enrollment record", 'error = result);
        return {
            message: result.message(),
            'error: "UPDATE_STUDENT_SUBJECT_ENROLLMENT_ERROR"
        };
    }

    return {
        message: "Student subject enrollment record updated successfully",
        data: result
    };
}

// Function to delete student subject enrollment record (hard delete)
public isolated function deleteStudentSubjectEnrollment(int recordId) returns DeleteStudentSubjectEnrollmentResponse|ErrorResponse|error {
    int|error result = studentSubjectEnrollmentDbConnection.deleteStudentSubjectEnrollment(recordId);

    if result is error {
        log:printError("Failed to delete student subject enrollment record", 'error = result);
        return {
            message: result.message(),
            'error: "DELETE_ERROR"
        };
    }

    return {
        message: "Student subject enrollment record deleted successfully",
        record_id: result
    };
}

// Function to get student subject enrollment by record ID
public isolated function getStudentSubjectEnrollmentById(int recordId) returns GetStudentSubjectEnrollmentByIdResponse|ErrorResponse|error {
    StudentSubjectEnrollment|error result = studentSubjectEnrollmentDbConnection.getStudentSubjectEnrollmentById(recordId);

    if result is error {
        log:printError("Failed to retrieve student subject enrollment record", 'error = result);
        return {
            message: result.message(),
            'error: "RECORD_NOT_FOUND"
        };
    }

    return {
        message: "Student subject enrollment record retrieved successfully",
        data: result
    };
}

// Function to get all student subject enrollments with subject details by student ID and course ID
public isolated function getStudentSubjectEnrollmentsWithDetails(int studentId, int courseId) returns GetStudentSubjectEnrollmentsWithDetailsResponse|ErrorResponse|error {
    // Validate that the student exists
    boolean|error studentValidation = studentSubjectEnrollmentDbConnection.validateStudentExists(studentId);
    
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

    // Validate that the course exists
    boolean|error courseValidation = studentSubjectEnrollmentDbConnection.validateCourseExists(courseId);
    
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

    // Validate that student is enrolled in the course
    boolean|error enrollmentValidation = studentSubjectEnrollmentDbConnection.isStudentEnrolledInCourse(studentId, courseId);
    
    if enrollmentValidation is error {
        log:printError("Failed to validate student course enrollment", 'error = enrollmentValidation);
        return {
            message: enrollmentValidation.message(),
            'error: "ENROLLMENT_VALIDATION_ERROR"
        };
    }
    
    if enrollmentValidation is boolean && !enrollmentValidation {
        return {
            message: "Student is not enrolled in the specified course",
            'error: "STUDENT_NOT_ENROLLED_IN_COURSE"
        };
    }

    StudentSubjectEnrollmentWithDetails[]|error result = studentSubjectEnrollmentDbConnection.getStudentSubjectEnrollmentsWithDetails(studentId, courseId);

    if result is error {
        log:printError("Failed to retrieve student subject enrollments with details", 'error = result);
        return {
            message: result.message(),
            'error: "FETCH_ERROR"
        };
    }

    return {
        message: "Student subject enrollments with details retrieved successfully",
        data: result
    };
}
