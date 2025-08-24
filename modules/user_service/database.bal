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

    // Add user with profile
    public isolated function addUserWithProfile(string email, string password, UserRole role, string name, string? phoneNumber, string? dob) returns UserWithProfile|error {
        string hashedPassword = check self.hashPassword(password);

        // Start a transaction
        sql:ExecutionResult _ = check self.dbClient->execute(`START TRANSACTION`);

        // Insert user
        sql:ParameterizedQuery userQuery = `
            INSERT INTO user (email, password, role) 
            VALUES (${email}, ${hashedPassword}, ${role})
        `;
        sql:ExecutionResult userResult = check self.dbClient->execute(userQuery);

        if userResult.affectedRowCount == 0 {
            sql:ExecutionResult _ = check self.dbClient->execute(`ROLLBACK`);
            return error("Failed to create user");
        }

        int|string? userId = userResult.lastInsertId;
        if userId is () {
            sql:ExecutionResult _ = check self.dbClient->execute(`ROLLBACK`);
            return error("Failed to get user ID");
        }

        // Insert profile
        sql:ParameterizedQuery profileQuery = `
            INSERT INTO profile (name, phone_number, dob, user_id) 
            VALUES (${name}, ${phoneNumber}, ${dob}, ${userId})
        `;
        sql:ExecutionResult profileResult = check self.dbClient->execute(profileQuery);

        if profileResult.affectedRowCount == 0 {
            sql:ExecutionResult _ = check self.dbClient->execute(`ROLLBACK`);
            return error("Failed to create profile");
        }

        int|string? profileId = profileResult.lastInsertId;
        if profileId is () {
            sql:ExecutionResult _ = check self.dbClient->execute(`ROLLBACK`);
            return error("Failed to get profile ID");
        }

        // Commit transaction
        sql:ExecutionResult _ = check self.dbClient->execute(`COMMIT`);

        return {
            user: {
                user_id: <int>userId,
                email: email,
                role: role
            },
            profile: {
                profile_id: <int>profileId,
                name: name,
                phone_number: phoneNumber,
                dob: dob,
                user_id: <int>userId
            }
        };
    }

    // Hash password using SHA-256
    public isolated function hashPassword(string password) returns string|error {
        byte[] hashedBytes = crypto:hashSha256(password.toBytes());
        return hashedBytes.toBase16();
    }
}

// Global database connection instance
final DatabaseConnection dbConnection = check new DatabaseConnection();
