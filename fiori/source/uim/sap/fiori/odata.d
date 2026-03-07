/**
 * OData client for Fiori services
 * 
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.fiori.odata;

import vibe.d;
import uim.sap.fiori.models;
import uim.sap.fiori.exceptions;
import std.conv : to;
import std.format : format;
import std.array : join;

/**
 * OData client for interacting with Gateway services
 */
class ODataClient {
    private FioriConfig config;
    private HTTPClient httpClient;
    private string csrfToken;
    
    /**
     * Constructor
     */
    this(FioriConfig config) {
        this.config = config;
        this.httpClient = new HTTPClient();
        this.httpClient.keepAlive = true;
    }
    
    /**
     * Fetch CSRF token
     */
    string fetchCSRFToken() {
        auto url = config.odataBaseUrl();
        auto headers = buildHeaders();
        headers["X-CSRF-Token"] = "Fetch";
        
        try {
            auto res = httpClient.request((scope req) {
                req.method = HTTPMethod.GET;
                req.requestURL = url;
                foreach (key, value; headers) {
                    req.headers[key] = value;
                }
            });
            
            csrfToken = res.headers.get("X-CSRF-Token", "");
            return csrfToken;
        } catch (Exception e) {
            throw new ODataException("Failed to fetch CSRF token: " ~ e.msg, 0);
        }
    }
    
    /**
     * Read entity set with query options
     */
    Json readEntitySet(string entitySet, ODataQueryOptions options = ODataQueryOptions.init) {
        auto url = buildUrl(entitySet, options);
        auto headers = buildHeaders();
        
        try {
            auto res = httpClient.request((scope req) {
                req.method = HTTPMethod.GET;
                req.requestURL = url;
                foreach (key, value; headers) {
                    req.headers[key] = value;
                }
            });
            
            if (res.statusCode >= 400) {
                auto errorBody = res.bodyReader.readAllUTF8();
                auto error = ODataError.fromJson(parseJsonString(errorBody));
                throw new ODataException(error.message, res.statusCode, error);
            }
            
            return res.readJson();
        } catch (ODataException e) {
            throw e;
        } catch (Exception e) {
            throw new ODataException("Failed to read entity set: " ~ e.msg, 0);
        }
    }
    
    /**
     * Read single entity by key
     */
    Json readEntity(string entitySet, string key) {
        auto url = config.odataBaseUrl() ~ "/" ~ entitySet ~ "('" ~ key ~ "')";
        auto headers = buildHeaders();
        
        try {
            auto res = httpClient.request((scope req) {
                req.method = HTTPMethod.GET;
                req.requestURL = url;
                foreach (key, value; headers) {
                    req.headers[key] = value;
                }
            });
            
            if (res.statusCode >= 400) {
                auto errorBody = res.bodyReader.readAllUTF8();
                auto error = ODataError.fromJson(parseJsonString(errorBody));
                throw new ODataException(error.message, res.statusCode, error);
            }
            
            return res.readJson();
        } catch (ODataException e) {
            throw e;
        } catch (Exception e) {
            throw new ODataException("Failed to read entity: " ~ e.msg, 0);
        }
    }
    
    /**
     * Create entity
     */
    Json createEntity(string entitySet, Json data) {
        ensureCSRFToken();
        
        auto url = config.odataBaseUrl() ~ "/" ~ entitySet;
        auto headers = buildHeaders();
        headers["X-CSRF-Token"] = csrfToken;
        headers["Content-Type"] = "application/json";
        
        try {
            auto res = httpClient.request((scope req) {
                req.method = HTTPMethod.POST;
                req.requestURL = url;
                foreach (key, value; headers) {
                    req.headers[key] = value;
                }
                req.writeJsonBody(data);
            });
            
            if (res.statusCode >= 400) {
                auto errorBody = res.bodyReader.readAllUTF8();
                auto error = ODataError.fromJson(parseJsonString(errorBody));
                throw new ODataException(error.message, res.statusCode, error);
            }
            
            return res.readJson();
        } catch (ODataException e) {
            throw e;
        } catch (Exception e) {
            throw new ODataException("Failed to create entity: " ~ e.msg, 0);
        }
    }
    
    /**
     * Update entity
     */
    Json updateEntity(string entitySet, string key, Json data, bool usePatch = true) {
        ensureCSRFToken();
        
        auto url = config.odataBaseUrl() ~ "/" ~ entitySet ~ "('" ~ key ~ "')";
        auto headers = buildHeaders();
        headers["X-CSRF-Token"] = csrfToken;
        headers["Content-Type"] = "application/json";
        
        try {
            auto res = httpClient.request((scope req) {
                req.method = usePatch ? HTTPMethod.PATCH : HTTPMethod.PUT;
                req.requestURL = url;
                foreach (key, value; headers) {
                    req.headers[key] = value;
                }
                req.writeJsonBody(data);
            });
            
            if (res.statusCode >= 400) {
                auto errorBody = res.bodyReader.readAllUTF8();
                auto error = ODataError.fromJson(parseJsonString(errorBody));
                throw new ODataException(error.message, res.statusCode, error);
            }
            
            // OData may return 204 No Content for successful updates
            if (res.statusCode == 204) {
                return Json.emptyObject;
            }
            
            return res.readJson();
        } catch (ODataException e) {
            throw e;
        } catch (Exception e) {
            throw new ODataException("Failed to update entity: " ~ e.msg, 0);
        }
    }
    
    /**
     * Delete entity
     */
    void deleteEntity(string entitySet, string key) {
        ensureCSRFToken();
        
        auto url = config.odataBaseUrl() ~ "/" ~ entitySet ~ "('" ~ key ~ "')";
        auto headers = buildHeaders();
        headers["X-CSRF-Token"] = csrfToken;
        
        try {
            auto res = httpClient.request((scope req) {
                req.method = HTTPMethod.DELETE;
                req.requestURL = url;
                foreach (key, value; headers) {
                    req.headers[key] = value;
                }
            });
            
            if (res.statusCode >= 400) {
                auto errorBody = res.bodyReader.readAllUTF8();
                auto error = ODataError.fromJson(parseJsonString(errorBody));
                throw new ODataException(error.message, res.statusCode, error);
            }
        } catch (ODataException e) {
            throw e;
        } catch (Exception e) {
            throw new ODataException("Failed to delete entity: " ~ e.msg, 0);
        }
    }
    
    /**
     * Execute function import
     */
    Json callFunction(string functionName, Json parameters = Json.emptyObject) {
        auto url = config.odataBaseUrl() ~ "/" ~ functionName;
        
        if (parameters.length > 0) {
            string[] params;
            foreach (key, value; parameters.byKeyValue) {
                params ~= format("%s=%s", key, value.to!string);
            }
            url ~= "?" ~ params.join("&");
        }
        
        auto headers = buildHeaders();
        
        try {
            auto res = httpClient.request((scope req) {
                req.method = HTTPMethod.GET;
                req.requestURL = url;
                foreach (key, value; headers) {
                    req.headers[key] = value;
                }
            });
            
            if (res.statusCode >= 400) {
                auto errorBody = res.bodyReader.readAllUTF8();
                auto error = ODataError.fromJson(parseJsonString(errorBody));
                throw new ODataException(error.message, res.statusCode, error);
            }
            
            return res.readJson();
        } catch (ODataException e) {
            throw e;
        } catch (Exception e) {
            throw new ODataException("Failed to execute function: " ~ e.msg, 0);
        }
    }
    
    /**
     * Fetch metadata document
     */
    string fetchMetadata() {
        auto url = config.odataBaseUrl() ~ "/$metadata";
        auto headers = buildHeaders();
        
        try {
            auto res = httpClient.request((scope req) {
                req.method = HTTPMethod.GET;
                req.requestURL = url;
                foreach (key, value; headers) {
                    req.headers[key] = value;
                }
            });
            
            if (res.statusCode >= 400) {
                throw new MetadataException("Failed to fetch metadata: HTTP " ~ res.statusCode.to!string);
            }
            
            return res.bodyReader.readAllUTF8();
        } catch (Exception e) {
            throw new MetadataException("Failed to fetch metadata: " ~ e.msg);
        }
    }
    
    /**
     * Execute batch request
     */
    ODataBatchResponse[] executeBatch(ODataBatchRequest[] requests) {
        ensureCSRFToken();
        
        import std.uuid : randomUUID;
        auto batchId = "batch_" ~ randomUUID().toString();
        auto changesetId = "changeset_" ~ randomUUID().toString();
        
        auto url = config.odataBaseUrl() ~ "/$batch";
        auto headers = buildHeaders();
        headers["X-CSRF-Token"] = csrfToken;
        headers["Content-Type"] = "multipart/mixed;boundary=" ~ batchId;
        
        // Build batch body
        string batchBody = buildBatchBody(requests, batchId, changesetId);
        
        try {
            auto res = httpClient.request((scope req) {
                req.method = HTTPMethod.POST;
                req.requestURL = url;
                foreach (key, value; headers) {
                    req.headers[key] = value;
                }
                req.bodyWriter.write(batchBody);
            });
            
            if (res.statusCode >= 400) {
                throw new ODataException("Batch request failed: HTTP " ~ res.statusCode.to!string, res.statusCode);
            }
            
            auto responseBody = res.bodyReader.readAllUTF8();
            return parseBatchResponse(responseBody);
        } catch (ODataException e) {
            throw e;
        } catch (Exception e) {
            throw new ODataException("Failed to execute batch: " ~ e.msg, 0);
        }
    }
    
    private void ensureCSRFToken() {
        if (config.enableCSRF && csrfToken.length == 0) {
            fetchCSRFToken();
        }
    }
    
    private string[string] buildHeaders() {
        string[string] headers;
        headers["Accept"] = "application/json";
        
        // Authentication
        final switch (config.authType) {
            case AuthenticationType.Basic:
                import std.base64 : Base64;
                auto credentials = config.username ~ ":" ~ config.password;
                headers["Authorization"] = "Basic " ~ Base64.encode(cast(ubyte[])credentials);
                break;
            case AuthenticationType.OAuth2:
                headers["Authorization"] = "Bearer " ~ config.oauthToken;
                break;
            case AuthenticationType.ApiKey:
                headers["APIKey"] = config.apiKey;
                break;
            case AuthenticationType.SAML:
            case AuthenticationType.Certificate:
                // These would be handled by the HTTP client configuration
                break;
        }
        
        // SAP-specific headers
        if (config.sapClient.length > 0) {
            headers["sap-client"] = config.sapClient;
        }
        
        if (config.sapLanguage.length > 0) {
            headers["sap-language"] = config.sapLanguage;
        }
        
        // Custom headers
        foreach (key, value; config.customHeaders) {
            headers[key] = value;
        }
        
        return headers;
    }
    
    private string buildUrl(string entitySet, ODataQueryOptions options) {
        auto url = config.odataBaseUrl() ~ "/" ~ entitySet;
        auto queryString = options.toQueryString();
        
        if (queryString.length > 0) {
            url ~= "?" ~ queryString;
        }
        
        return url;
    }
    
    private string buildBatchBody(ODataBatchRequest[] requests, string batchId, string changesetId) {
        import std.array : appender;
        auto body = appender!string;
        
        body ~= "--" ~ batchId ~ "\r\n";
        body ~= "Content-Type: multipart/mixed;boundary=" ~ changesetId ~ "\r\n\r\n";
        
        foreach (i, req; requests) {
            body ~= "--" ~ changesetId ~ "\r\n";
            body ~= "Content-Type: application/http\r\n";
            body ~= "Content-Transfer-Encoding: binary\r\n";
            
            if (req.contentId.length > 0) {
                body ~= "Content-ID: " ~ req.contentId ~ "\r\n";
            }
            
            body ~= "\r\n";
            body ~= req.method ~ " " ~ req.url ~ " HTTP/1.1\r\n";
            
            foreach (key, value; req.headers) {
                body ~= key ~ ": " ~ value ~ "\r\n";
            }
            
            if (!req.body.isUndefined) {
                auto jsonBody = req.body.toString();
                body ~= "Content-Length: " ~ jsonBody.length.to!string ~ "\r\n";
                body ~= "\r\n";
                body ~= jsonBody ~ "\r\n";
            } else {
                body ~= "\r\n";
            }
        }
        
        body ~= "--" ~ changesetId ~ "--\r\n";
        body ~= "--" ~ batchId ~ "--\r\n";
        
        return body.data;
    }
    
    private ODataBatchResponse[] parseBatchResponse(string responseBody) {
        // Simplified batch response parsing
        // In production, would need full multipart/mixed parser
        ODataBatchResponse[] responses;
        return responses;
    }
}
