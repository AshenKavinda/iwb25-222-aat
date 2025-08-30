import ballerina/jwt;
import ballerina/uuid;

// JWT configuration
configurable string JWT_SECRET = ?;
configurable int ACCESS_TOKEN_EXPIRY_TIME = ?; // 1 hour in seconds
configurable int REFRESH_TOKEN_EXPIRY_TIME = ?; // 7 days in seconds

// JWT utilities
public isolated class JwtUtils {

    public isolated function generateAccessToken(User user) returns string|error {
        jwt:IssuerSignatureConfig signatureConfig = {
            algorithm: jwt:HS256,
            config: JWT_SECRET
        };
        
        jwt:IssuerConfig issuerConfig = {
            username: user.email,
            issuer: "school-performance-auth",
            audience: ["school-performance-api"],
            expTime: <decimal>ACCESS_TOKEN_EXPIRY_TIME,
            customClaims: {
                "user_id": user.user_id,
                "email": user.email,
                "role": user.role,
                "jti": uuid:createType1AsString(),
                "type": "access"
            },
            signatureConfig: signatureConfig
        };

        return jwt:issue(issuerConfig);
    }

    public isolated function generateRefreshToken(User user) returns string|error {
        jwt:IssuerSignatureConfig signatureConfig = {
            algorithm: jwt:HS256,
            config: JWT_SECRET
        };
        
        jwt:IssuerConfig issuerConfig = {
            username: user.email,
            issuer: "school-performance-auth",
            audience: ["school-performance-refresh"],
            expTime: <decimal>REFRESH_TOKEN_EXPIRY_TIME,
            customClaims: {
                "user_id": user.user_id,
                "email": user.email,
                "role": user.role,
                "jti": uuid:createType1AsString(),
                "type": "refresh"
            },
            signatureConfig: signatureConfig
        };

        return jwt:issue(issuerConfig);
    }

    public isolated function validateAccessToken(string token) returns JwtPayload|error {
        jwt:ValidatorConfig validatorConfig = {
            issuer: "school-performance-auth",
            audience: ["school-performance-api"],
            clockSkew: 60
        };

        jwt:Payload payload = check jwt:validate(token, validatorConfig);
        
        // Extract claims directly from payload
        anydata userIdData = payload["user_id"];
        anydata emailData = payload["email"];
        anydata roleData = payload["role"];
        anydata jtiData = payload["jti"];
        anydata typeData = payload["type"];
        
        if userIdData is () || emailData is () || roleData is () || jtiData is () || typeData is () {
            return error("Required claims not found in token");
        }
        
        // Verify this is an access token
        string tokenType = <string>typeData;
        if tokenType != "access" {
            return error("Invalid token type");
        }
        
        int userId = <int>userIdData;
        string email = <string>emailData;
        UserRole role = <UserRole>roleData;
        string jti = <string>jtiData;
        
        return {
            user_id: userId,
            email: email,
            role: role,
            exp: <int>payload.exp,
            iat: <int>payload.iat,
            jti: jti
        };
    }

    public isolated function validateRefreshToken(string token) returns JwtPayload|error {
        jwt:ValidatorConfig validatorConfig = {
            issuer: "school-performance-auth",
            audience: ["school-performance-refresh"],
            clockSkew: 60
        };

        jwt:Payload payload = check jwt:validate(token, validatorConfig);
        
        // Extract claims directly from payload
        anydata userIdData = payload["user_id"];
        anydata emailData = payload["email"];
        anydata roleData = payload["role"];
        anydata jtiData = payload["jti"];
        anydata typeData = payload["type"];
        
        if userIdData is () || emailData is () || roleData is () || jtiData is () || typeData is () {
            return error("Required claims not found in token");
        }
        
        // Verify this is a refresh token
        string tokenType = <string>typeData;
        if tokenType != "refresh" {
            return error("Invalid token type");
        }
        
        int userId = <int>userIdData;
        string email = <string>emailData;
        UserRole role = <UserRole>roleData;
        string jti = <string>jtiData;
        
        return {
            user_id: userId,
            email: email,
            role: role,
            exp: <int>payload.exp,
            iat: <int>payload.iat,
            jti: jti
        };
    }

    public isolated function extractTokenFromHeader(string authHeader) returns string|error {
        if !authHeader.startsWith("Bearer ") {
            return error("Invalid authorization header format");
        }
        
        string token = authHeader.substring(7); // Remove "Bearer " prefix
        if token.length() == 0 {
            return error("Token not found in authorization header");
        }
        
        return token;
    }
}

// Global JWT utilities instance
final JwtUtils jwtUtils = new JwtUtils();
