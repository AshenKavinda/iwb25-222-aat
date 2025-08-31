import ballerina/log;

// Function to add course with user validation
public isolated function addCourse(AddCourseRequest addCourseReq) returns AddCourseResponse|ErrorResponse|error {
    // First validate that the user exists and is an officer
    boolean|error userValidation = courseDbConnection.validateUserIsOfficer(addCourseReq.user_id);
    
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

    Course|error result = courseDbConnection.addCourse(
        addCourseReq.name, addCourseReq?.hall, addCourseReq.year, addCourseReq.user_id
    );

    if result is error {
        log:printError("Failed to add course", 'error = result);
        return {
            message: result.message(),
            'error: "ADD_COURSE_ERROR"
        };
    }

    return {
        message: "Course added successfully",
        data: result
    };
}

// Function to update course
public isolated function updateCourse(int courseId, UpdateCourseRequest updateCourseReq) returns UpdateCourseResponse|ErrorResponse|error {
    // First validate that the course exists and belongs to a valid officer
    boolean|error courseValidation = courseDbConnection.validateCourseBelongsToOfficer(courseId);
    
    if courseValidation is error {
        log:printError("Failed to validate course", 'error = courseValidation);
        return {
            message: courseValidation.message(),
            'error: "COURSE_VALIDATION_ERROR"
        };
    }
    
    if courseValidation is boolean && !courseValidation {
        return {
            message: "Course not found or does not belong to a valid officer",
            'error: "INVALID_COURSE_OR_USER"
        };
    }

    Course|error result = courseDbConnection.updateCourse(
        courseId, updateCourseReq?.name, updateCourseReq?.hall, updateCourseReq?.year
    );

    if result is error {
        log:printError("Failed to update course", 'error = result);
        return {
            message: result.message(),
            'error: "UPDATE_COURSE_ERROR"
        };
    }

    return {
        message: "Course updated successfully",
        data: result
    };
}

// Function to soft delete course
public isolated function softDeleteCourse(int courseId) returns DeleteCourseResponse|ErrorResponse|error {
    // First validate that the course exists and belongs to a valid officer
    boolean|error courseValidation = courseDbConnection.validateCourseBelongsToOfficer(courseId);
    
    if courseValidation is error {
        log:printError("Failed to validate course", 'error = courseValidation);
        return {
            message: courseValidation.message(),
            'error: "COURSE_VALIDATION_ERROR"
        };
    }
    
    if courseValidation is boolean && !courseValidation {
        return {
            message: "Course not found or does not belong to a valid officer",
            'error: "INVALID_COURSE_OR_USER"
        };
    }

    int|error result = courseDbConnection.softDeleteCourse(courseId);

    if result is error {
        log:printError("Failed to delete course", 'error = result);
        return {
            message: result.message(),
            'error: "DELETE_ERROR"
        };
    }

    return {
        message: "Course deleted successfully",
        course_id: result
    };
}

// Function to restore course
public isolated function restoreCourse(int courseId) returns RestoreCourseResponse|ErrorResponse|error {
    // First validate that the deleted course exists and belongs to a valid officer
    boolean|error courseValidation = courseDbConnection.validateDeletedCourseBelongsToOfficer(courseId);
    
    if courseValidation is error {
        log:printError("Failed to validate deleted course", 'error = courseValidation);
        return {
            message: courseValidation.message(),
            'error: "COURSE_VALIDATION_ERROR"
        };
    }
    
    if courseValidation is boolean && !courseValidation {
        return {
            message: "Deleted course not found or does not belong to a valid officer",
            'error: "INVALID_COURSE_OR_USER"
        };
    }

    Course|error result = courseDbConnection.restoreCourse(courseId);

    if result is error {
        log:printError("Failed to restore course", 'error = result);
        return {
            message: result.message(),
            'error: "RESTORE_ERROR"
        };
    }

    return {
        message: "Course restored successfully",
        data: result
    };
}

// Function to get all courses
public isolated function getAllCourses() returns GetAllCoursesResponse|ErrorResponse|error {
    Course[]|error result = courseDbConnection.getAllCourses();

    if result is error {
        log:printError("Failed to retrieve courses", 'error = result);
        return {
            message: result.message(),
            'error: "FETCH_ERROR"
        };
    }

    return {
        message: "Courses retrieved successfully",
        data: result
    };
}

// Function to get course by ID
public isolated function getCourseById(int courseId) returns GetCourseByIdResponse|ErrorResponse|error {
    Course|error result = courseDbConnection.getCourseById(courseId);

    if result is error {
        log:printError("Failed to retrieve course", 'error = result);
        return {
            message: result.message(),
            'error: "COURSE_NOT_FOUND"
        };
    }

    return {
        message: "Course retrieved successfully",
        data: result
    };
}

// Function to get all deleted courses
public isolated function getDeletedCourses() returns GetDeletedCoursesResponse|ErrorResponse|error {
    Course[]|error result = courseDbConnection.getDeletedCourses();

    if result is error {
        log:printError("Failed to retrieve deleted courses", 'error = result);
        return {
            message: result.message(),
            'error: "FETCH_ERROR"
        };
    }

    return {
        message: "Deleted courses retrieved successfully",
        data: result
    };
}

// Function to get all available years
public isolated function getAvailableYears() returns GetAvailableYearsResponse|ErrorResponse|error {
    string[]|error result = courseDbConnection.getAvailableYears();

    if result is error {
        log:printError("Failed to retrieve available years", 'error = result);
        return {
            message: result.message(),
            'error: "FETCH_ERROR"
        };
    }

    return {
        message: "Available years retrieved successfully",
        data: result
    };
}

// Function to search courses by name and year
public isolated function searchCoursesByNameAndYear(string? name, string? year) returns SearchCoursesByNameAndYearResponse|ErrorResponse|error {
    // Add wildcard pattern for LIKE search if name is provided
    string? namePattern = name is string ? "%" + name + "%" : ();
    
    Course[]|error result = courseDbConnection.searchCoursesByNameAndYear(namePattern, year);

    if result is error {
        log:printError("Failed to search courses by name and year", 'error = result);
        return {
            message: result.message(),
            'error: "SEARCH_ERROR"
        };
    }

    return {
        message: "Courses found successfully",
        data: result
    };
}
