import ballerina/http;
import ballerina/log;

// Subject REST API service
public service class SubjectRestService {
    *http:Service;
    
    // Add new subject
    resource function post .(AddSubjectRequest addSubjectReq) returns AddSubjectResponse|ErrorResponse|http:InternalServerError {
        AddSubjectResponse|ErrorResponse|error result = addSubject(addSubjectReq);
        
        if result is error {
            log:printError("Internal server error while adding subject", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
    
    // Get all subjects
    resource function get .() returns GetAllSubjectsResponse|ErrorResponse|http:InternalServerError {
        GetAllSubjectsResponse|ErrorResponse|error result = getAllSubjects();
        
        if result is error {
            log:printError("Internal server error while retrieving subjects", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
    
    // Get subject by ID
    resource function get [int subjectId]() returns GetSubjectByIdResponse|ErrorResponse|http:InternalServerError {
        GetSubjectByIdResponse|ErrorResponse|error result = getSubjectById(subjectId);
        
        if result is error {
            log:printError("Internal server error while retrieving subject", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
    
    // Update subject
    resource function put [int subjectId](UpdateSubjectRequest updateSubjectReq) returns UpdateSubjectResponse|ErrorResponse|http:InternalServerError {
        UpdateSubjectResponse|ErrorResponse|error result = updateSubject(subjectId, updateSubjectReq);
        
        if result is error {
            log:printError("Internal server error while updating subject", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
    
    // Soft delete subject
    resource function delete [int subjectId]() returns DeleteSubjectResponse|ErrorResponse|http:InternalServerError {
        DeleteSubjectResponse|ErrorResponse|error result = softDeleteSubject(subjectId);
        
        if result is error {
            log:printError("Internal server error while deleting subject", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
    
    // Restore subject
    resource function post [int subjectId]/restore() returns RestoreSubjectResponse|ErrorResponse|http:InternalServerError {
        RestoreSubjectResponse|ErrorResponse|error result = restoreSubject(subjectId);
        
        if result is error {
            log:printError("Internal server error while restoring subject", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
    
    // Get all deleted subjects
    resource function get deleted() returns GetDeletedSubjectsResponse|ErrorResponse|http:InternalServerError {
        GetDeletedSubjectsResponse|ErrorResponse|error result = getDeletedSubjects();
        
        if result is error {
            log:printError("Internal server error while retrieving deleted subjects", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
    
    // Search subjects by name
    resource function get search/[string name]() returns SearchSubjectsByNameResponse|ErrorResponse|http:InternalServerError {
        SearchSubjectsByNameResponse|ErrorResponse|error result = searchSubjectsByName(name);
        
        if result is error {
            log:printError("Internal server error while searching subjects", 'error = result);
            return http:INTERNAL_SERVER_ERROR;
        }
        
        return result;
    }
}

// Get subject service instance
public isolated function getSubjectService() returns SubjectRestService {
    return new SubjectRestService();
}
