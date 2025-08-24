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

    // Update user with profile (no password or email updates allowed)
    public isolated function updateUserWithProfile(int userId, UserRole? role, string? name, string? phoneNumber, string? dob) returns UserWithProfile|error {
        // Start a transaction
        sql:ExecutionResult _ = check self.dbClient->execute(`START TRANSACTION`);

        // Update user role if provided
        if role is UserRole {
            sql:ParameterizedQuery userQuery = `UPDATE user SET role = ${role}, updated_at = NOW() WHERE user_id = ${userId}`;
            sql:ExecutionResult userResult = check self.dbClient->execute(userQuery);
            if userResult.affectedRowCount == 0 {
                sql:ExecutionResult _ = check self.dbClient->execute(`ROLLBACK`);
                return error("User not found or failed to update user");
            }
        }

        // Update profile if any profile fields are provided
        if name is string || phoneNumber is string || dob is string {
            sql:ParameterizedQuery profileQuery;
            if name is string && phoneNumber is string && dob is string {
                profileQuery = `UPDATE profile SET name = ${name}, phone_number = ${phoneNumber}, dob = ${dob}, updated_at = NOW() WHERE user_id = ${userId}`;
            } else if name is string && phoneNumber is string {
                profileQuery = `UPDATE profile SET name = ${name}, phone_number = ${phoneNumber}, updated_at = NOW() WHERE user_id = ${userId}`;
            } else if name is string && dob is string {
                profileQuery = `UPDATE profile SET name = ${name}, dob = ${dob}, updated_at = NOW() WHERE user_id = ${userId}`;
            } else if phoneNumber is string && dob is string {
                profileQuery = `UPDATE profile SET phone_number = ${phoneNumber}, dob = ${dob}, updated_at = NOW() WHERE user_id = ${userId}`;
            } else if name is string {
                profileQuery = `UPDATE profile SET name = ${name}, updated_at = NOW() WHERE user_id = ${userId}`;
            } else if phoneNumber is string {
                profileQuery = `UPDATE profile SET phone_number = ${phoneNumber}, updated_at = NOW() WHERE user_id = ${userId}`;
            } else {
                profileQuery = `UPDATE profile SET dob = ${dob}, updated_at = NOW() WHERE user_id = ${userId}`;
            }

            sql:ExecutionResult profileResult = check self.dbClient->execute(profileQuery);
            if profileResult.affectedRowCount == 0 {
                sql:ExecutionResult _ = check self.dbClient->execute(`ROLLBACK`);
                return error("Profile not found or failed to update profile");
            }
        }

        // Commit transaction
        sql:ExecutionResult _ = check self.dbClient->execute(`COMMIT`);

        // Get updated user with profile
        sql:ParameterizedQuery selectQuery = `
            SELECT u.user_id, u.email, u.role, u.created_at, u.updated_at, u.deleted_at,
                   p.profile_id, p.name, p.phone_number, p.dob, p.created_at as profile_created_at, 
                   p.updated_at as profile_updated_at, p.deleted_at as profile_deleted_at
            FROM user u 
            LEFT JOIN profile p ON u.user_id = p.user_id 
            WHERE u.user_id = ${userId}
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        record {|record {} value;|}? result = check resultStream.next();
        check resultStream.close();

        if result is () {
            return error("Updated user not found");
        }

        record {} userData = result.value;
        
        return {
            user: {
                user_id: <int>userData["user_id"],
                email: <string>userData["email"],
                role: <UserRole>userData["role"],
                created_at: userData["created_at"].toString(),
                updated_at: userData["updated_at"].toString(),
                deleted_at: userData["deleted_at"] is () ? () : userData["deleted_at"].toString()
            },
            profile: {
                profile_id: <int>userData["profile_id"],
                name: <string>userData["name"],
                phone_number: userData["phone_number"] is () ? () : <string>userData["phone_number"],
                dob: userData["dob"] is () ? () : <string>userData["dob"],
                user_id: <int>userData["user_id"],
                created_at: userData["profile_created_at"].toString(),
                updated_at: userData["profile_updated_at"].toString(),
                deleted_at: userData["profile_deleted_at"] is () ? () : userData["profile_deleted_at"].toString()
            }
        };
    }

    // Soft delete user and profile
    public isolated function softDeleteUser(int userId) returns int|error {
        // Start a transaction
        sql:ExecutionResult _ = check self.dbClient->execute(`START TRANSACTION`);

        // Soft delete user
        sql:ParameterizedQuery userQuery = `UPDATE user SET deleted_at = NOW() WHERE user_id = ${userId} AND deleted_at IS NULL`;
        sql:ExecutionResult userResult = check self.dbClient->execute(userQuery);
        if userResult.affectedRowCount == 0 {
            sql:ExecutionResult _ = check self.dbClient->execute(`ROLLBACK`);
            return error("User not found or already deleted");
        }

        // Soft delete profile
        sql:ParameterizedQuery profileQuery = `UPDATE profile SET deleted_at = NOW() WHERE user_id = ${userId} AND deleted_at IS NULL`;
        sql:ExecutionResult _ = check self.dbClient->execute(profileQuery);

        // Commit transaction
        sql:ExecutionResult _ = check self.dbClient->execute(`COMMIT`);

        return userId;
    }

    // Restore soft deleted user and profile
    public isolated function restoreUser(int userId) returns UserWithProfile|error {
        // Start a transaction
        sql:ExecutionResult _ = check self.dbClient->execute(`START TRANSACTION`);

        // Restore user
        sql:ParameterizedQuery userQuery = `UPDATE user SET deleted_at = NULL WHERE user_id = ${userId} AND deleted_at IS NOT NULL`;
        sql:ExecutionResult userResult = check self.dbClient->execute(userQuery);
        if userResult.affectedRowCount == 0 {
            sql:ExecutionResult _ = check self.dbClient->execute(`ROLLBACK`);
            return error("User not found or not deleted");
        }

        // Restore profile
        sql:ParameterizedQuery profileQuery = `UPDATE profile SET deleted_at = NULL WHERE user_id = ${userId} AND deleted_at IS NOT NULL`;
        sql:ExecutionResult _ = check self.dbClient->execute(profileQuery);

        // Commit transaction
        sql:ExecutionResult _ = check self.dbClient->execute(`COMMIT`);

        // Get restored user with profile
        sql:ParameterizedQuery selectQuery = `
            SELECT u.user_id, u.email, u.role, u.created_at, u.updated_at, u.deleted_at,
                   p.profile_id, p.name, p.phone_number, p.dob, p.created_at as profile_created_at, 
                   p.updated_at as profile_updated_at, p.deleted_at as profile_deleted_at
            FROM user u 
            LEFT JOIN profile p ON u.user_id = p.user_id 
            WHERE u.user_id = ${userId}
        `;
        
        stream<record {}, error?> resultStream = self.dbClient->query(selectQuery);
        record {|record {} value;|}? result = check resultStream.next();
        check resultStream.close();

        if result is () {
            return error("Restored user not found");
        }

        record {} userData = result.value;
        
        return {
            user: {
                user_id: <int>userData["user_id"],
                email: <string>userData["email"],
                role: <UserRole>userData["role"],
                created_at: userData["created_at"].toString(),
                updated_at: userData["updated_at"].toString(),
                deleted_at: userData["deleted_at"] is () ? () : userData["deleted_at"].toString()
            },
            profile: {
                profile_id: <int>userData["profile_id"],
                name: <string>userData["name"],
                phone_number: userData["phone_number"] is () ? () : <string>userData["phone_number"],
                dob: userData["dob"] is () ? () : <string>userData["dob"],
                user_id: <int>userData["user_id"],
                created_at: userData["profile_created_at"].toString(),
                updated_at: userData["profile_updated_at"].toString(),
                deleted_at: userData["profile_deleted_at"] is () ? () : userData["profile_deleted_at"].toString()
            }
        };
    }
}

// Global database connection instance
final DatabaseConnection dbConnection = check new DatabaseConnection();
