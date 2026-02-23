/**
 * Connection configuration for SAP HANA Cloud
 * 
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.models.connection;

import uim.sap.models.credential;
import uim.sap.exceptions;
import std.string : format;
import core.time : Duration, seconds;

/**
 * Connection configuration for SAP HANA Cloud
 */
struct ConnectionConfig {
    /// Host address (e.g., "myaccount.hanacloud.ondemand.com")
    string host;
    
    /// Port number (default: 443 for HTTPS)
    ushort port = 443;
    
    /// Use HTTPS (recommended)
    bool useSSL = true;
    
    /// Database name/schema
    string database;
    
    /// Instance ID
    string instanceId;
    
    /// Authentication credentials
    Credential credential;
    
    /// Connection timeout
    Duration timeout = 30.seconds;
    
    /// Maximum number of retry attempts
    uint maxRetries = 3;
    
    /// Verify SSL certificates
    bool verifySSL = true;
    
    /// Custom headers to include in requests
    string[string] customHeaders;
    
    /**
     * Validate the configuration
     */
    void validate() const @safe {
        if (host.length == 0) {
            throw new SAPConfigurationException("Host cannot be empty");
        }
        
        if (port == 0) {
            throw new SAPConfigurationException("Invalid port number");
        }
        
        if (database.length == 0) {
            throw new SAPConfigurationException("Database name cannot be empty");
        }
    }
    
    /**
     * Get the base URL for API requests
     */
    string baseUrl() const pure @safe {
        auto protocol = useSSL ? "https" : "http";
        if ((useSSL && port == 443) || (!useSSL && port == 80)) {
            return format("%s://%s", protocol, host);
        }
        return format("%s://%s:%d", protocol, host, port);
    }
    
    /**
     * Get the full database URL
     */
    string databaseUrl() const pure @safe {
        return format("%s/%s", baseUrl(), database);
    }
    
    /**
     * Create a default SAP HANA Cloud configuration
     */
    static ConnectionConfig create(string host, string database, Credential credential) pure nothrow @safe {
        ConnectionConfig config;
        config.host = host;
        config.database = database;
        config.credential = credential;
        return config;
    }
}
