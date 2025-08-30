// Shared database configuration for all services
// This module provides centralized database configuration

// Database configuration (from global Config.toml)
configurable string DB_HOST = ?;
configurable int DB_PORT = ?;
configurable string DB_USERNAME = ?;
configurable string DB_PASSWORD = ?;
configurable string DB_NAME = ?;

// Isolated function to get database configuration
public isolated function getDatabaseConfig() returns DatabaseConfig {
    return {
        host: DB_HOST,
        port: DB_PORT,
        username: DB_USERNAME,
        password: DB_PASSWORD,
        database: DB_NAME
    };
}

// Database configuration record type
public type DatabaseConfig record {|
    readonly string host;
    readonly int port;
    readonly string username;
    readonly string password;
    readonly string database;
|};
