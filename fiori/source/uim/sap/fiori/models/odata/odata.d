/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.fiori.models.odata.odata;

import uim.sap.fiori;
@safe:

/**
 * OData collection response
 */
struct ODataCollection(T) {
    T[] results;
    long count;
    string nextLink;
    ODataEntityMeta[] metadata;
    
    /**
     * Check if there are more results
     */
    @property bool hasMore() const pure nothrow @safe @nogc {
        return nextLink.length > 0;
    }
}

/**
 * OData error detail
 */
struct ODataErrorDetail {
    string code;
    string message;
    string target;
    string severity;
}

/**
 * OData error response
 */
struct ODataError {
    string code;
    string message;
    string target;
    ODataErrorDetail[] details;
    Json innerError;
    
    /**
     * Parse from JSON response
     */
    static ODataError fromJson(Json json) {
        ODataError error;
        
        // OData v2 format: { "error": { "code": ..., "message": { "value": ... } } }
        // OData v4 format: { "error": { "code": ..., "message": ... } }
        
        if ("error" in json) {
            auto errorObj = json["error"];
            
            if ("code" in errorObj) {
                error.code = errorObj["code"].getString;
            }
            
            if ("message" in errorObj) {
                if (errorObj["message"].isObject && "value" in errorObj["message"]) {
                    // OData v2
                    error.message = errorObj["message"]["value"].getString;
                } else if (errorObj["message"].isString) {
                    // OData v4
                    error.message = errorObj["message"].getString;
                }
            }
            
            if ("target" in errorObj) {
                error.target = errorObj["target"].getString;
            }
            
            if ("innererror" in errorObj || "innerError" in errorObj) {
                error.innerError = "innererror" in errorObj ? errorObj["innererror"] : errorObj["innerError"];
            }
        }
        
        return error;
    }
}

/**
 * OData batch request
 */
struct ODataBatchRequest {
    string method;     // GET, POST, PUT, PATCH, DELETE
    string url;
    string[string] headers;
    Json data;
    string contentId;  // For referencing in batch
}

/**
 * OData batch response
 */
struct ODataBatchResponse {
    int statusCode;
    string[string] headers;
    Json data;
    string contentId;
}

/**
 * OData metadata document
 */
struct ODataMetadata {
    string version_;
    string dataServiceVersion;
    ODataEntitySet[] entitySets;
    ODataEntityType[] entityTypes;
    ODataFunctionImport[] functionImports;
}

/**
 * OData entity set
 */
struct ODataEntitySet {
    string name;
    string entityType;
}

/**
 * OData entity type
 */
struct ODataEntityType {
    string name;
    string namespace;
    ODataProperty[] properties;
    ODataNavigationProperty[] navigationProperties;
    string[] keys;
}

/**
 * OData property
 */
struct ODataProperty {
    string name;
    string type;
    bool nullable = true;
    int maxLength;
    int precision;
    int scale;
}

/**
 * OData navigation property
 */
struct ODataNavigationProperty {
    string name;
    string relationship;
    string fromRole;
    string toRole;
}

/**
 * OData function import
 */
struct ODataFunctionImport {
    string name;
    string returnType;
    string httpMethod;
    ODataParameter[] parameters;
}

/**
 * OData function parameter
 */
struct ODataParameter {
    string name;
    string type;
    string mode;  // In, Out, InOut
}
