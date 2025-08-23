import ballerina/sql;
import ballerinax/mysql;
import ballerina/crypto;

// Database configuration
configurable string DB_HOST = "127.0.0.1";
configurable int DB_PORT = 3306;
configurable string DB_USERNAME = "root";
configurable string DB_PASSWORD = "Ashen#321";
configurable string DB_NAME = "school_performance";

// Database connection class
public isolated class DatabaseConnection {
    private final mysql:Client dbClient;

    public isolated function init() returns error? {
        self.dbClient = check new (
            host = DB_HOST,
            port = DB_PORT,
            user = DB_USERNAME,
            password = DB_PASSWORD,
            database = DB_NAME
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

    // Hash password using SHA-256
    public isolated function hashPassword(string password) returns string|error {
        byte[] hashedBytes = crypto:hashSha256(password.toBytes());
        return hashedBytes.toBase16();
    }

    // Verify password
    public isolated function verifyPassword(string password, string hashedPassword) returns boolean|error {
        string hashedInput = check self.hashPassword(password);
        return hashedInput == hashedPassword;
    }

    // Create user
    public isolated function createUser(string email, string password, UserRole role) returns User|error {
        string hashedPassword = check self.hashPassword(password);
        
        sql:ParameterizedQuery query = `
            INSERT INTO user (email, password, role) 
            VALUES (${email}, ${hashedPassword}, ${role})
        `;
        
        sql:ExecutionResult result = check self.dbClient->execute(query);
        
        if result.affectedRowCount == 0 {
            return error("Failed to create user");
        }
        
        int|string? userId = result.lastInsertId;
        if userId is () {
            return error("Failed to get user ID");
        }
        
        return {
            user_id: <int>userId,
            email: email,
            role: role
        };
    }

    // Get user by email
    public isolated function getUserByEmail(string email) returns User|error? {
        sql:ParameterizedQuery query = `
            SELECT user_id, email, password, role, created_at, updated_at, deleted_at 
            FROM user 
            WHERE email = ${email} AND deleted_at IS NULL
        `;
        
        stream<User, error?> userStream = self.dbClient->query(query);
        record {|User value;|}? user = check userStream.next();
        check userStream.close();
        
        if user is () {
            return ();
        }
        
        return user.value;
    }

    // Get user by ID
    public isolated function getUserById(int userId) returns User|error? {
        sql:ParameterizedQuery query = `
            SELECT user_id, email, password, role, created_at, updated_at, deleted_at 
            FROM user 
            WHERE user_id = ${userId} AND deleted_at IS NULL
        `;
        
        stream<User, error?> userStream = self.dbClient->query(query);
        record {|User value;|}? user = check userStream.next();
        check userStream.close();
        
        if user is () {
            return ();
        }
        
        return user.value;
    }

    // Create profile
    public isolated function createProfile(string name, string? phoneNumber, string? dob, int userId) returns Profile|error {
        sql:ParameterizedQuery query = `
            INSERT INTO profile (name, phone_number, dob, user_id) 
            VALUES (${name}, ${phoneNumber}, ${dob}, ${userId})
        `;
        
        sql:ExecutionResult result = check self.dbClient->execute(query);
        
        if result.affectedRowCount == 0 {
            return error("Failed to create profile");
        }
        
        int|string? profileId = result.lastInsertId;
        if profileId is () {
            return error("Failed to get profile ID");
        }
        
        return {
            profile_id: <int>profileId,
            name: name,
            phone_number: phoneNumber,
            dob: dob,
            user_id: userId
        };
    }

    // Get profile by user ID
    public isolated function getProfileByUserId(int userId) returns Profile|error? {
        sql:ParameterizedQuery query = `
            SELECT profile_id, name, phone_number, dob, user_id, created_at, updated_at, deleted_at 
            FROM profile 
            WHERE user_id = ${userId} AND deleted_at IS NULL
        `;
        
        stream<Profile, error?> profileStream = self.dbClient->query(query);
        record {|Profile value;|}? profile = check profileStream.next();
        check profileStream.close();
        
        if profile is () {
            return ();
        }
        
        return profile.value;
    }

    // Check if email exists
    public isolated function emailExists(string email) returns boolean|error {
        sql:ParameterizedQuery query = `
            SELECT COUNT(*) as count 
            FROM user 
            WHERE email = ${email} AND deleted_at IS NULL
        `;
        
        stream<record {int count;}, error?> countStream = self.dbClient->query(query);
        record {|record {int count;} value;|}? countRecord = check countStream.next();
        check countStream.close();
        
        if countRecord is () {
            return false;
        }
        
        return countRecord.value.count > 0;
    }
}

// Global database connection instance
final DatabaseConnection dbConnection = check new DatabaseConnection();
