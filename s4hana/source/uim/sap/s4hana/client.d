/**
 * SAP S/4HANA client
 */
module uim.sap.s4hana.client;

import std.base64 : Base64;
import std.datetime : Clock;
import std.string : format;

import vibe.data.json : Json;
import vibe.http.client : requestHTTP, HTTPClientRequest;
import vibe.http.common : HTTPMethod;
import vibe.textfilter.urlencode : urlEncode;

import uim.sap.s4hana.config;
import uim.sap.s4hana.exceptions;
import uim.sap.s4hana.models;

class SAPS4HANAClient {
    private SAPS4HANAConfig _config;

    this(SAPS4HANAConfig config) {
        config.validate();
        _config = config;
    }

    @property const(SAPS4HANAConfig) config() const {
        return _config;
    }

    bool testConnection() {
        try {
            auto response = getOData("API_BUSINESS_PARTNER", "$metadata");
            return response.success;
        } catch (Exception) {
            return false;
        }
    }

    SAPS4HANAResponse getOData(
        string servicePath,
        string entityPath,
        string[string] query = null
    ) {
        auto req = SAPS4HANARequest(servicePath, entityPath, query, Json.emptyObject);
        return request(HTTPMethod.GET, req);
    }

    SAPS4HANAResponse postOData(
        string servicePath,
        string entityPath,
        Json payload,
        string[string] query = null
    ) {
        auto req = SAPS4HANARequest(servicePath, entityPath, query, payload);
        return request(HTTPMethod.POST, req);
    }

    SAPS4HANAResponse getBusinessPartners(uint top = 20, uint skip = 0) {
        string[string] query;
        query["$top"] = format("%d", top);
        query["$skip"] = format("%d", skip);

        return getOData("API_BUSINESS_PARTNER", "A_BusinessPartner", query);
    }

    SAPS4HANAResponse request(
        HTTPMethod method,
        string path,
        Json payload = Json.emptyObject,
        string[string] query = null,
        bool isAbsolute = false
    ) {
        SAPS4HANARequest req;

        if (isAbsolute) {
            req.servicePath = "";
            req.entityPath = "";
        } else {
            req.servicePath = "";
            req.entityPath = path;
        }

        req.query = query;
        req.payload = payload;

        return executeRequest(method, req, isAbsolute ? path : "");
    }

    SAPS4HANAResponse request(HTTPMethod method, SAPS4HANARequest request) {
        return executeRequest(method, request, "");
    }

    private SAPS4HANAResponse executeRequest(
        HTTPMethod method,
        SAPS4HANARequest request,
        string absoluteUrl
    ) {
        auto url = absoluteUrl.length > 0
            ? absoluteUrl
            : _config.odataBaseUrl() ~ "/" ~ request.requestPath();

        auto queryString = buildQueryString(request.query);
        if (queryString.length > 0) {
            url ~= (url.indexOf('?') >= 0 ? "&" : "?") ~ queryString;
        }

        uint attempts = 0;
        while (attempts <= _config.maxRetries) {
            try {
                SAPS4HANAResponse response;
                response.timestamp = Clock.currTime();

                requestHTTP(url,
                    (scope req) {
                        req.method = method;
                        req.headers["Accept"] = "application/json";

                        applyAuth(req);
                        applySAPHeaders(req);

                        foreach (key, value; _config.customHeaders) {
                            req.headers[key] = value;
                        }

                        if (method == HTTPMethod.POST || method == HTTPMethod.PUT || method == HTTPMethod.PATCH) {
                            req.headers["Content-Type"] = "application/json";
                            req.writeJsonBody(request.payload);
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
                    throw new SAPS4HANARequestException(response.errorMessage, response.statusCode);
                }

                return response;
            } catch (SAPS4HANARequestException e) {
                throw e;
            } catch (Exception e) {
                attempts++;
                if (attempts > _config.maxRetries) {
                    throw new SAPS4HANAConnectionException(
                        format("SAP S/4HANA request failed after %d retries: %s", attempts, e.msg)
                    );
                }
            }
        }

        throw new SAPS4HANAConnectionException("SAP S/4HANA request failed with unknown error");
    }

    private string buildQueryString(string[string] query) {
        if (query is null || query.length == 0) {
            return "";
        }

        bool first = true;
        string buffer;

        foreach (key, value; query) {
            if (!first) {
                buffer ~= "&";
            }
            first = false;

            buffer ~= urlEncode(key);
            buffer ~= "=";
            buffer ~= urlEncode(value);
        }

        return buffer;
    }

    private string extractErrorMessage(Json data, int statusCode) {
        if ("error" in data) {
            auto errorObj = data["error"];

            if (errorObj.type == Json.Type.object && "message" in errorObj) {
                auto msg = errorObj["message"];

                if (msg.type == Json.Type.string) {
                    return msg.get!string;
                }

                if (msg.type == Json.Type.object && "value" in msg) {
                    return msg["value"].get!string;
                }
            }
        }

        return format("SAP S/4HANA request failed with status code %d", statusCode);
    }

    private void applyAuth(HTTPClientRequest req) {
        final switch (_config.authType) {
            case SAPS4HANAAuthType.Basic:
                auto creds = _config.username ~ ":" ~ _config.password;
                auto token = Base64.encode(cast(const(ubyte)[])creds).idup;
                req.headers["Authorization"] = "Basic " ~ token;
                break;
            case SAPS4HANAAuthType.OAuth2:
                req.headers["Authorization"] = "Bearer " ~ _config.accessToken;
                break;
            case SAPS4HANAAuthType.ApiKey:
                req.headers[_config.apiKeyHeader] = _config.apiKey;
                break;
        }
    }

    private void applySAPHeaders(HTTPClientRequest req) {
        if (_config.sapClient.length > 0) {
            req.headers["sap-client"] = _config.sapClient;
        }

        if (_config.sapLanguage.length > 0) {
            req.headers["sap-language"] = _config.sapLanguage;
        }
    }
}
