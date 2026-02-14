/**
 * SAP RFC adapter client
 *
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.rfc.client;

import std.string : format;
import std.base64 : Base64;
import std.datetime : Clock;

import vibe.http.client : requestHTTP, HTTPClientRequest;
import vibe.http.common : HTTPMethod;
import vibe.data.json : Json;

import uim.sap.rfc.config;
import uim.sap.rfc.models;
import uim.sap.rfc.exceptions;

class SAPRFCClient {
    private SAPRFCConfig _config;

    this(SAPRFCConfig config) {
        config.validate();
        _config = config;
    }

    @property const(SAPRFCConfig) config() const {
        return _config;
    }

    bool testConnection() {
        try {
            auto response = ping();
            return response.success;
        } catch (Exception) {
            return false;
        }
    }

    SAPRFCResponse ping() {
        SAPRFCRequest request;
        request.functionName = "RFC_PING";
        request.parameters = Json.emptyObject;
        return invoke(request);
    }

    SAPRFCResponse invoke(
        string functionName,
        Json parameters = Json.emptyObject,
        string destination = ""
    ) {
        SAPRFCRequest request;
        request.functionName = functionName;
        request.parameters = parameters;
        request.destination = destination;

        return invoke(request);
    }

    SAPRFCResponse invoke(SAPRFCRequest request) {
        if (request.functionName.length == 0) {
            throw new SAPRFCInvocationException("RFC function name cannot be empty");
        }

        auto url = format("%s/%s", _config.serviceUrl(), request.functionName);

        uint attempts = 0;
        while (attempts <= _config.maxRetries) {
            try {
                SAPRFCResponse response;
                response.timestamp = Clock.currTime();

                requestHTTP(url,
                    (scope req) {
                        req.method = HTTPMethod.POST;
                        req.headers["Content-Type"] = "application/json";
                        req.headers["Accept"] = "application/json";

                        applyAuth(req);
                        applySAPHeaders(req);

                        foreach (key, value; _config.customHeaders) {
                            req.headers[key] = value;
                        }

                        req.writeJsonBody(request.toJson());
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
                            if ("error" in response.data && response.data["error"].type == Json.Type.string) {
                                response.errorMessage = response.data["error"].get!string;
                            } else {
                                response.errorMessage = format(
                                    "RFC invocation failed with status code %d",
                                    res.statusCode
                                );
                            }
                        }
                    }
                );

                if (!response.success) {
                    throw new SAPRFCInvocationException(response.errorMessage, response.statusCode);
                }

                return response;
            } catch (SAPRFCInvocationException e) {
                throw e;
            } catch (Exception e) {
                attempts++;
                if (attempts > _config.maxRetries) {
                    throw new SAPRFCConnectionException(
                        format("RFC request failed after %d retries: %s", attempts, e.msg)
                    );
                }
            }
        }

        throw new SAPRFCConnectionException("RFC request failed with unknown error");
    }

    private void applyAuth(HTTPClientRequest req) {
        final switch (_config.authType) {
            case SAPRFCAuthType.None:
                break;
            case SAPRFCAuthType.Basic:
                auto creds = _config.username ~ ":" ~ _config.password;
                auto token = Base64.encode(cast(const(ubyte)[])creds);
                req.headers["Authorization"] = "Basic " ~ token;
                break;
            case SAPRFCAuthType.Bearer:
                req.headers["Authorization"] = "Bearer " ~ _config.bearerToken;
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
