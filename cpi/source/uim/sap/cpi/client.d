/**
 * SAP Cloud Integration (CPI) client
 */
module uim.sap.cpi.client;

import std.base64 : Base64;
import std.datetime : Clock;
import std.string : format, startsWith;

import vibe.data.json : Json;
import vibe.http.client : requestHTTP, HTTPClientRequest;
import vibe.http.common : HTTPMethod;
import vibe.textfilter.urlencode : urlEncode;

import uim.sap.cpi.config;
import uim.sap.cpi.exceptions;
import uim.sap.cpi.models;

class SAPCPIClient {
    private SAPCPIConfig _config;

    this(SAPCPIConfig config) {
        config.validate();
        _config = config;
    }

    @property const(SAPCPIConfig) config() const {
        return _config;
    }

    bool testConnection() {
        try {
            auto response = get("/IntegrationRuntimeArtifacts", null, true);
            return response.success;
        } catch (Exception) {
            return false;
        }
    }

    SAPCPIResponse get(string path, string[string] query = null, bool useApiBase = true) {
        return executeRequest(HTTPMethod.GET, path, Json.emptyObject, query, useApiBase);
    }

    SAPCPIResponse post(
        string path,
        Json payload,
        string[string] query = null,
        bool useApiBase = true
    ) {
        return executeRequest(HTTPMethod.POST, path, payload, query, useApiBase);
    }

    SAPCPIResponse getIntegrationArtifacts(uint top = 20, uint skip = 0) {
        string[string] query;
        query["$top"] = format("%d", top);
        query["$skip"] = format("%d", skip);
        return get("/IntegrationRuntimeArtifacts", query, true);
    }

    SAPCPIResponse getMessageProcessingLogs(uint top = 20, uint skip = 0, string status = "") {
        string[string] query;
        query["$top"] = format("%d", top);
        query["$skip"] = format("%d", skip);
        if (status.length > 0) {
            query["$filter"] = "Status eq '" ~ status ~ "'";
        }
        return get("/MessageProcessingLogs", query, true);
    }

    SAPCPIResponse triggerIntegrationFlow(
        string endpointPath,
        Json payload = Json.emptyObject,
        string[string] query = null
    ) {
        if (endpointPath.length == 0) {
            throw new SAPCPIRequestException("Endpoint path cannot be empty");
        }
        return post(endpointPath, payload, query, false);
    }

    private SAPCPIResponse executeRequest(
        HTTPMethod method,
        string path,
        Json payload,
        string[string] query,
        bool useApiBase
    ) {
        auto url = buildUrl(path, query, useApiBase);

        uint attempts = 0;
        while (attempts <= _config.maxRetries) {
            try {
                SAPCPIResponse response;
                response.timestamp = Clock.currTime();

                requestHTTP(url,
                    (scope req) {
                        req.method = method;
                        req.headers["Accept"] = "application/json";

                        applyAuth(req);

                        foreach (key, value; _config.customHeaders) {
                            req.headers[key] = value;
                        }

                        if (method == HTTPMethod.POST || method == HTTPMethod.PUT || method == HTTPMethod.PATCH) {
                            req.headers["Content-Type"] = "application/json";
                            req.writeJsonBody(payload);
                        }
                    },
                    (scope res) {
                        response.statusCode = res.statusCode;
                        response.success = res.statusCode >= 200 && res.statusCode < 300;

                        try {
                            response.data = res.readJson();
                        } catch (Exception) {
                            response.data = Json.emptyObject;
                        }

                        if (!response.success) {
                            response.errorMessage = extractErrorMessage(response.data, res.statusCode);
                        }
                    }
                );

                if (!response.success) {
                    throw new SAPCPIRequestException(response.errorMessage, response.statusCode);
                }

                return response;
            } catch (SAPCPIRequestException e) {
                throw e;
            } catch (Exception e) {
                attempts++;
                if (attempts > _config.maxRetries) {
                    throw new SAPCPIConnectionException(
                        format("SAP CPI request failed after %d retries: %s", attempts, e.msg)
                    );
                }
            }
        }

        throw new SAPCPIConnectionException("SAP CPI request failed with unknown error");
    }

    private string buildUrl(string path, string[string] query, bool useApiBase) {
        auto normalizedPath = path.length == 0 ? "/" : path;
        if (!normalizedPath.startsWith("/")) {
            normalizedPath = "/" ~ normalizedPath;
        }

        auto base = useApiBase ? _config.apiBaseUrl() : _config.fullBaseUrl();
        auto url = base ~ normalizedPath;

        auto queryString = buildQueryString(query);
        if (queryString.length > 0) {
            url ~= (url.indexOf('?') >= 0 ? "&" : "?") ~ queryString;
        }

        return url;
    }

    private string buildQueryString(string[string] query) {
        if (query is null || query.length == 0) {
            return "";
        }

        bool first = true;
        string builder;

        foreach (key, value; query) {
            if (!first) {
                builder ~= "&";
            }
            first = false;
            builder ~= urlEncode(key) ~ "=" ~ urlEncode(value);
        }

        return builder;
    }

    private string extractErrorMessage(Json data, int statusCode) {
        if ("error" in data) {
            auto errorObj = data["error"];
            if (errorObj.type == Json.Type.object) {
                if ("message" in errorObj) {
                    auto msg = errorObj["message"];
                    if (msg.type == Json.Type.string) {
                        return msg.get!string;
                    }
                    if (msg.type == Json.Type.object && "value" in msg) {
                        return msg["value"].get!string;
                    }
                }
            }
        }

        return format("SAP CPI request failed with status code %d", statusCode);
    }

    private void applyAuth(HTTPClientRequest req) {
        final switch (_config.authType) {
            case SAPCPIAuthType.Basic:
                auto creds = _config.username ~ ":" ~ _config.password;
                auto token = Base64.encode(cast(const(ubyte)[])creds).idup;
                req.headers["Authorization"] = "Basic " ~ token;
                break;
            case SAPCPIAuthType.OAuth2:
                req.headers["Authorization"] = "Bearer " ~ _config.accessToken;
                break;
            case SAPCPIAuthType.ApiKey:
                req.headers[_config.apiKeyHeader] = _config.apiKey;
                break;
        }
    }
}
