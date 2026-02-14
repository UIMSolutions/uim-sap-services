/**
 * Response models for SAP HANA operations
 * 
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.hcd.models.responses.sapresponse;

import vibe.data.json;
import std.datetime : SysTime;

/**
 * SAP HANA API response
 */
struct SAPResponse {
    /// HTTP status code
    int statusCode;
    
    /// Success indicator
    bool success;
    
    /// Response body as JSON
    Json data;
    
    /// Error message if any
    string errorMessage;
    
    /// Error code if any
    int errorCode;
    
    /// Response headers
    string[string] headers;
    
    /// Request timestamp
    SysTime timestamp;
    
    /**
     * Check if the response indicates success
     */
    bool isSuccess() const pure nothrow @safe @nogc {
        return success && statusCode >= 200 && statusCode < 300;
    }
    
    /**
     * Check if the response indicates an error
     */
    bool isError() const pure nothrow @safe @nogc {
        return !success || statusCode >= 400;
    }
}
