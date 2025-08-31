import ballerina/log;

// Function to add test enrollments with user validation
public isolated function addTestEnrollments(AddTestEnrollmentRequest addTestEnrollmentReq) returns AddTestEnrollmentResponse|ErrorResponse|error {
    // First validate that the user exists and is an officer
    boolean|error userValidation = testEnrollmentDbConnection.validateUserIsOfficer(addTestEnrollmentReq.user_id);
    
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

    // Validate that course exists
    boolean|error courseValidation = testEnrollmentDbConnection.validateCourseExists(addTestEnrollmentReq.course_id);
    
    if courseValidation is error {
        log:printError("Failed to validate course", 'error = courseValidation);
        return {
            message: courseValidation.message(),
            'error: "COURSE_VALIDATION_ERROR"
        };
    }
    
    if courseValidation is boolean && !courseValidation {
        return {
            message: "Course does not exist",
            'error: "INVALID_COURSE"
        };
    }

    // Validate test IDs array is not empty
    if addTestEnrollmentReq.test_ids.length() == 0 {
        return {
            message: "Test IDs array cannot be empty",
            'error: "EMPTY_TEST_IDS"
        };
    }

    // Get tests with their subject information
    TestInfo[]|error testInfos = testEnrollmentDbConnection.getTestsWithSubjects(addTestEnrollmentReq.test_ids);
    
    if testInfos is error {
        log:printError("Failed to get test information", 'error = testInfos);
        return {
            message: testInfos.message(),
            'error: "TEST_INFO_ERROR"
        };
    }

    // Validate that all requested tests were found
    if testInfos.length() != addTestEnrollmentReq.test_ids.length() {
        return {
            message: "Some test IDs are invalid or tests are deleted",
            'error: "INVALID_TEST_IDS"
        };
    }

    // Extract unique subject IDs from tests
    int[] subjectIds = [];
    foreach TestInfo testInfo in testInfos {
        boolean subjectExists = false;
        foreach int subjectId in subjectIds {
            if subjectId == testInfo.subject_id {
                subjectExists = true;
                break;
            }
        }
        if !subjectExists {
            subjectIds.push(testInfo.subject_id);
        }
    }

    // Get students enrolled in these subjects for the course
    StudentInfo[]|error students = testEnrollmentDbConnection.getStudentsForSubjectsInCourse(addTestEnrollmentReq.course_id, subjectIds);
    
    if students is error {
        log:printError("Failed to get students for subjects in course", 'error = students);
        return {
            message: students.message(),
            'error: "STUDENTS_FETCH_ERROR"
        };
    }

    if students.length() == 0 {
        return {
            message: "No students found for the specified subjects in this course",
            'error: "NO_STUDENTS_FOUND"
        };
    }

    // Create enrollments for each student and test combination
    int totalRecordsCreated = 0;
    foreach StudentInfo student in students {
        foreach TestInfo testInfo in testInfos {
            // Only create enrollment if student is enrolled in the test's subject
            StudentInfo[]|error studentSubjectCheck = testEnrollmentDbConnection.getStudentsForSubjectsInCourse(addTestEnrollmentReq.course_id, [testInfo.subject_id]);
            
            if studentSubjectCheck is error {
                log:printError("Failed to validate student subject enrollment", 'error = studentSubjectCheck);
                continue;
            }

            boolean studentEnrolledInSubject = false;
            foreach StudentInfo enrolledStudent in studentSubjectCheck {
                if enrolledStudent.student_id == student.student_id {
                    studentEnrolledInSubject = true;
                    break;
                }
            }

            if studentEnrolledInSubject {
                int|error recordId = testEnrollmentDbConnection.addTestEnrollment(
                    student.student_id, 
                    addTestEnrollmentReq.course_id, 
                    testInfo.subject_id, 
                    testInfo.test_id, 
                    addTestEnrollmentReq.user_id
                );

                if recordId is int {
                    totalRecordsCreated += 1;
                } else {
                    log:printWarn("Failed to create test enrollment for student " + student.student_id.toString() + " and test " + testInfo.test_id.toString(), 'error = recordId);
                }
            }
        }
    }

    // Get course and subject names for response
    string|error courseName = testEnrollmentDbConnection.getCourseName(addTestEnrollmentReq.course_id);
    string[]|error subjectNames = testEnrollmentDbConnection.getSubjectNames(subjectIds);

    string finalCourseName = courseName is string ? courseName : "Unknown Course";
    string[] finalSubjectNames = subjectNames is string[] ? subjectNames : [];

    TestEnrollmentDetails enrollmentDetails = {
        course_id: addTestEnrollmentReq.course_id,
        course_name: finalCourseName,
        test_ids: addTestEnrollmentReq.test_ids,
        subject_ids: subjectIds,
        subject_names: finalSubjectNames,
        total_students_enrolled: students.length(),
        total_records_created: totalRecordsCreated
    };

    return {
        message: "Test enrollments created successfully",
        data: enrollmentDetails
    };
}

// Function to delete test enrollments
public isolated function deleteTestEnrollments(DeleteTestEnrollmentRequest deleteTestEnrollmentReq) returns DeleteTestEnrollmentResponse|ErrorResponse|error {
    // First validate that the user exists and is an officer
    boolean|error userValidation = testEnrollmentDbConnection.validateUserIsOfficer(deleteTestEnrollmentReq.user_id);
    
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

    // Validate that course exists
    boolean|error courseValidation = testEnrollmentDbConnection.validateCourseExists(deleteTestEnrollmentReq.course_id);
    
    if courseValidation is error {
        log:printError("Failed to validate course", 'error = courseValidation);
        return {
            message: courseValidation.message(),
            'error: "COURSE_VALIDATION_ERROR"
        };
    }
    
    if courseValidation is boolean && !courseValidation {
        return {
            message: "Course does not exist",
            'error: "INVALID_COURSE"
        };
    }

    // Validate test IDs array is not empty
    if deleteTestEnrollmentReq.test_ids.length() == 0 {
        return {
            message: "Test IDs array cannot be empty",
            'error: "EMPTY_TEST_IDS"
        };
    }

    // Delete test enrollment records
    int|error affectedRecords = testEnrollmentDbConnection.deleteTestEnrollments(deleteTestEnrollmentReq.course_id, deleteTestEnrollmentReq.test_ids);
    
    if affectedRecords is error {
        log:printError("Failed to delete test enrollments", 'error = affectedRecords);
        return {
            message: affectedRecords.message(),
            'error: "DELETE_ERROR"
        };
    }

    return {
        message: "Test enrollments deleted successfully",
        affected_records: affectedRecords
    };
}

// Function to get test enrollments by course ID and test ID
public isolated function getTestEnrollmentsByCourseAndTest(int courseId, int testId) returns GetTestEnrollmentsByCourseAndTestResponse|ErrorResponse|error {
    // Validate that course exists
    boolean|error courseValidation = testEnrollmentDbConnection.validateCourseExists(courseId);
    
    if courseValidation is error {
        log:printError("Failed to validate course", 'error = courseValidation);
        return {
            message: courseValidation.message(),
            'error: "COURSE_VALIDATION_ERROR"
        };
    }
    
    if courseValidation is boolean && !courseValidation {
        return {
            message: "Course does not exist",
            'error: "INVALID_COURSE"
        };
    }

    // Validate that test exists
    TestInfo[]|error testValidation = testEnrollmentDbConnection.getTestsWithSubjects([testId]);
    
    if testValidation is error {
        log:printError("Failed to validate test", 'error = testValidation);
        return {
            message: testValidation.message(),
            'error: "TEST_VALIDATION_ERROR"
        };
    }
    
    if testValidation.length() == 0 {
        return {
            message: "Test does not exist or is deleted",
            'error: "INVALID_TEST"
        };
    }

    // Get test enrollments
    TestEnrollmentWithDetails[]|error enrollments = testEnrollmentDbConnection.getTestEnrollmentsByCourseAndTest(courseId, testId);
    
    if enrollments is error {
        log:printError("Failed to get test enrollments", 'error = enrollments);
        return {
            message: enrollments.message(),
            'error: "FETCH_ERROR"
        };
    }

    return {
        message: "Test enrollments retrieved successfully",
        data: enrollments
    };
}

// Function to update mark by record ID with user validation
public isolated function updateMarkByRecordId(int recordId, UpdateMarkRequest updateMarkReq) returns UpdateMarkResponse|ErrorResponse|error {
    // First validate that the user exists and is an officer or teacher
    boolean|error userValidation = testEnrollmentDbConnection.validateUserIsOfficerOrTeacher(updateMarkReq.user_id);
    
    if userValidation is error {
        log:printError("Failed to validate user", 'error = userValidation);
        return {
            message: userValidation.message(),
            'error: "USER_VALIDATION_ERROR"
        };
    }
    
    if userValidation is boolean && !userValidation {
        return {
            message: "User ID does not exist or user is not an officer or teacher",
            'error: "INVALID_USER_OR_ROLE"
        };
    }

    // Validate mark range
    decimal minMark = 0.0d;
    decimal maxMark = 100.0d;
    if updateMarkReq.mark < minMark || updateMarkReq.mark > maxMark {
        return {
            message: "Mark must be between 0 and 100",
            'error: "INVALID_MARK_RANGE"
        };
    }

    // Update mark
    TestEnrollmentWithDetails|error result = testEnrollmentDbConnection.updateMark(recordId, updateMarkReq.mark);
    
    if result is error {
        log:printError("Failed to update mark", 'error = result);
        return {
            message: result.message(),
            'error: "UPDATE_ERROR"
        };
    }

    return {
        message: "Mark updated successfully",
        data: result
    };
}
