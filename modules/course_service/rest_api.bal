import ballerina/http;
import ballerina/log;

// Course REST API service
public service class CourseRestService {
    *http:Service;
    
    // Add new course
    resource function post .(AddCourseRequest addCourseReq) returns AddCourseResponse|ErrorResponse|http:InternalServerError {
        AddCourseResponse|ErrorResponse|error result = addCourse(addCourseReq);
        
        if result is error {
            log:printError("Internal server error while adding course", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
    
    // Get all courses
    resource function get .() returns GetAllCoursesResponse|ErrorResponse|http:InternalServerError {
        GetAllCoursesResponse|ErrorResponse|error result = getAllCourses();
        
        if result is error {
            log:printError("Internal server error while retrieving courses", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
    
    // Get course by ID
    resource function get [int courseId]() returns GetCourseByIdResponse|ErrorResponse|http:InternalServerError {
        GetCourseByIdResponse|ErrorResponse|error result = getCourseById(courseId);
        
        if result is error {
            log:printError("Internal server error while retrieving course", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
    
    // Update course
    resource function put [int courseId](UpdateCourseRequest updateCourseReq) returns UpdateCourseResponse|ErrorResponse|http:InternalServerError {
        UpdateCourseResponse|ErrorResponse|error result = updateCourse(courseId, updateCourseReq);
        
        if result is error {
            log:printError("Internal server error while updating course", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
    
    // Soft delete course
    resource function delete [int courseId]() returns DeleteCourseResponse|ErrorResponse|http:InternalServerError {
        DeleteCourseResponse|ErrorResponse|error result = softDeleteCourse(courseId);
        
        if result is error {
            log:printError("Internal server error while deleting course", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
    
    // Restore course
    resource function post [int courseId]/restore() returns RestoreCourseResponse|ErrorResponse|http:InternalServerError {
        RestoreCourseResponse|ErrorResponse|error result = restoreCourse(courseId);
        
        if result is error {
            log:printError("Internal server error while restoring course", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
    
    // Get all deleted courses
    resource function get deleted() returns GetDeletedCoursesResponse|ErrorResponse|http:InternalServerError {
        GetDeletedCoursesResponse|ErrorResponse|error result = getDeletedCourses();
        
        if result is error {
            log:printError("Internal server error while retrieving deleted courses", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
    
    // Get all available years
    resource function get years() returns GetAvailableYearsResponse|ErrorResponse|http:InternalServerError {
        GetAvailableYearsResponse|ErrorResponse|error result = getAvailableYears();
        
        if result is error {
            log:printError("Internal server error while retrieving available years", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
    
    // Search courses by name
    resource function get search/name/[string name]() returns SearchCoursesByNameAndYearResponse|ErrorResponse|http:InternalServerError {
        SearchCoursesByNameAndYearResponse|ErrorResponse|error result = searchCoursesByNameAndYear(name, ());
        
        if result is error {
            log:printError("Internal server error while searching courses by name", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
    
    // Search courses by year
    resource function get search/year/[string year]() returns SearchCoursesByNameAndYearResponse|ErrorResponse|http:InternalServerError {
        SearchCoursesByNameAndYearResponse|ErrorResponse|error result = searchCoursesByNameAndYear((), year);
        
        if result is error {
            log:printError("Internal server error while searching courses by year", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
    
    // Search courses by name and year
    resource function get search/name/[string name]/year/[string year]() returns SearchCoursesByNameAndYearResponse|ErrorResponse|http:InternalServerError {
        SearchCoursesByNameAndYearResponse|ErrorResponse|error result = searchCoursesByNameAndYear(name, year);
        
        if result is error {
            log:printError("Internal server error while searching courses by name and year", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
}

// Get course service instance
public isolated function getCourseService() returns CourseRestService {
    return new CourseRestService();
}
