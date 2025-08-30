import ballerina/sql;
import ballerinax/mysql;
import ashen/school_performance_panel.database_config;

// Database connection class for report operations
public isolated class ReportDatabaseConnection {
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

    // Get top performing students by term and year
    public isolated function getTopPerformingStudents(string year, string termType, int limitCount) returns TopPerformingStudent[]|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT s.student_id, s.full_name, c.name AS course_name, t.year, t.t_type, 
                   SUM(stcs.mark) AS total_marks
            FROM student_test_course_subject stcs
            JOIN student s ON stcs.student_id = s.student_id
            JOIN test t ON stcs.test_id = t.test_id
            JOIN course c ON stcs.course_id = c.course_id
            WHERE t.year = ${year} AND t.t_type = ${termType} 
                  AND s.deleted_at IS NULL AND t.deleted_at IS NULL AND c.deleted_at IS NULL
            GROUP BY s.student_id, s.full_name, c.name, t.year, t.t_type
            ORDER BY total_marks DESC
            LIMIT ${limitCount}
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        TopPerformingStudent[] students = [];

        check from record {} studentData in resultStream
            do {
                TopPerformingStudent student = {
                    student_id: <int>studentData["student_id"],
                    full_name: <string>studentData["full_name"],
                    course_name: <string>studentData["course_name"],
                    year: <string>studentData["year"],
                    t_type: <string>studentData["t_type"],
                    total_marks: studentData["total_marks"] is () ? 0.0 : <decimal>studentData["total_marks"]
                };
                students.push(student);
            };

        return students;
    }

    // Get average marks per subject by course and term
    public isolated function getAverageMarksBySubject(string year, string termType) returns AverageMarksBySubject[]|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT sub.name AS subject_name, c.name AS course_name, t.t_type, t.year,
                   AVG(stcs.mark) AS avg_mark
            FROM student_test_course_subject stcs
            JOIN subject sub ON stcs.subject_id = sub.subject_id
            JOIN course c ON stcs.course_id = c.course_id
            JOIN test t ON stcs.test_id = t.test_id
            WHERE t.year = ${year} AND t.t_type = ${termType}
                  AND sub.deleted_at IS NULL AND c.deleted_at IS NULL AND t.deleted_at IS NULL
            GROUP BY sub.name, c.name, t.t_type, t.year
            ORDER BY avg_mark DESC
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        AverageMarksBySubject[] subjects = [];

        check from record {} subjectData in resultStream
            do {
                AverageMarksBySubject subject = {
                    subject_name: <string>subjectData["subject_name"],
                    course_name: <string>subjectData["course_name"],
                    t_type: <string>subjectData["t_type"],
                    year: <string>subjectData["year"],
                    avg_mark: subjectData["avg_mark"] is () ? 0.0 : <decimal>subjectData["avg_mark"]
                };
                subjects.push(subject);
            };

        return subjects;
    }

    // Get teacher performance report
    public isolated function getTeacherPerformance() returns TeacherPerformance[]|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT u.user_id AS teacher_id, p.name AS teacher_name, sub.name AS subject_name,
                   AVG(stcs.mark) AS avg_student_marks
            FROM student_test_course_subject stcs
            JOIN subject sub ON stcs.subject_id = sub.subject_id
            JOIN subject_course_teacher sct ON sct.subject_id = sub.subject_id AND sct.course_id = stcs.course_id
            JOIN user u ON sct.teacher_id = u.user_id
            JOIN profile p ON p.user_id = u.user_id
            WHERE sub.deleted_at IS NULL AND u.deleted_at IS NULL AND p.deleted_at IS NULL
            GROUP BY u.user_id, p.name, sub.name
            ORDER BY avg_student_marks DESC
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        TeacherPerformance[] teachers = [];

        check from record {} teacherData in resultStream
            do {
                TeacherPerformance teacher = {
                    teacher_id: <int>teacherData["teacher_id"],
                    teacher_name: <string>teacherData["teacher_name"],
                    subject_name: <string>teacherData["subject_name"],
                    avg_student_marks: teacherData["avg_student_marks"] is () ? 0.0 : <decimal>teacherData["avg_student_marks"]
                };
                teachers.push(teacher);
            };

        return teachers;
    }

    // Get student progress across terms
    public isolated function getStudentProgress(string year) returns StudentProgress[]|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT s.full_name, sub.name AS subject_name, t.year,
                   SUM(CASE WHEN t.t_type = 'tm1' THEN stcs.mark ELSE 0 END) AS tm1_marks,
                   SUM(CASE WHEN t.t_type = 'tm2' THEN stcs.mark ELSE 0 END) AS tm2_marks,
                   SUM(CASE WHEN t.t_type = 'tm3' THEN stcs.mark ELSE 0 END) AS tm3_marks
            FROM student_test_course_subject stcs
            JOIN student s ON stcs.student_id = s.student_id
            JOIN subject sub ON stcs.subject_id = sub.subject_id
            JOIN test t ON stcs.test_id = t.test_id
            WHERE t.year = ${year}
                  AND s.deleted_at IS NULL AND sub.deleted_at IS NULL AND t.deleted_at IS NULL
            GROUP BY s.full_name, sub.name, t.year
            ORDER BY s.full_name, sub.name
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        StudentProgress[] progressList = [];

        check from record {} progressData in resultStream
            do {
                StudentProgress progress = {
                    full_name: <string>progressData["full_name"],
                    subject_name: <string>progressData["subject_name"],
                    year: <string>progressData["year"],
                    tm1_marks: progressData["tm1_marks"] is () ? 0.0 : <decimal>progressData["tm1_marks"],
                    tm2_marks: progressData["tm2_marks"] is () ? 0.0 : <decimal>progressData["tm2_marks"],
                    tm3_marks: progressData["tm3_marks"] is () ? 0.0 : <decimal>progressData["tm3_marks"]
                };
                progressList.push(progress);
            };

        return progressList;
    }

    // Get low performing subjects
    public isolated function getLowPerformingSubjects(string year, decimal threshold) returns LowPerformingSubject[]|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT sub.name AS subject_name, c.name AS course_name,
                   AVG(stcs.mark) AS avg_marks
            FROM student_test_course_subject stcs
            JOIN subject sub ON stcs.subject_id = sub.subject_id
            JOIN course c ON stcs.course_id = c.course_id
            JOIN test t ON stcs.test_id = t.test_id
            WHERE t.year = ${year}
                  AND sub.deleted_at IS NULL AND c.deleted_at IS NULL AND t.deleted_at IS NULL
            GROUP BY sub.name, c.name
            HAVING avg_marks < ${threshold}
            ORDER BY avg_marks ASC
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        LowPerformingSubject[] subjects = [];

        check from record {} subjectData in resultStream
            do {
                LowPerformingSubject subject = {
                    subject_name: <string>subjectData["subject_name"],
                    course_name: <string>subjectData["course_name"],
                    avg_marks: subjectData["avg_marks"] is () ? 0.0 : <decimal>subjectData["avg_marks"]
                };
                subjects.push(subject);
            };

        return subjects;
    }

    // Get top performing courses
    public isolated function getTopPerformingCourses(string year, string termType) returns TopPerformingCourse[]|error {
        sql:ParameterizedQuery selectQuery = `
            SELECT c.name AS course_name, t.year, t.t_type,
                   AVG(stcs.mark) AS avg_marks
            FROM student_test_course_subject stcs
            JOIN course c ON stcs.course_id = c.course_id
            JOIN test t ON stcs.test_id = t.test_id
            WHERE t.year = ${year} AND t.t_type = ${termType}
                  AND c.deleted_at IS NULL AND t.deleted_at IS NULL
            GROUP BY c.name, t.year, t.t_type
            ORDER BY avg_marks DESC
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        TopPerformingCourse[] courses = [];

        check from record {} courseData in resultStream
            do {
                TopPerformingCourse course = {
                    course_name: <string>courseData["course_name"],
                    year: <string>courseData["year"],
                    t_type: <string>courseData["t_type"],
                    avg_marks: courseData["avg_marks"] is () ? 0.0 : <decimal>courseData["avg_marks"]
                };
                courses.push(course);
            };

        return courses;
    }
}

// Global database connection instance
final ReportDatabaseConnection reportDbConnection = check new ReportDatabaseConnection();
