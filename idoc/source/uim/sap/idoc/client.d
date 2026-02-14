/**
 * SAP IDOC client
 *
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.idoc.client;

import std.base64 : Base64;
import std.datetime : Clock;
import std.string : format;

import vibe.data.json : Json;
import vibe.http.client : requestHTTP, HTTPClientRequest;
import vibe.http.common : HTTPMethod;
import vibe.textfilter.urlencode : urlEncode;

import uim.sap.idoc.config;
import uim.sap.idoc.exceptions;
import uim.sap.idoc.models;

class SAPIDocClient {
    private SAPIDocConfig _config;

    this(SAPIDocConfig config) {
        config.validate();
        _config = config;
    }

    @property const(SAPIDocConfig) config() const {
        return _config;
    }

    bool testConnection() {
        try {
            auto response = requestJSON(HTTPMethod.GET, _config.serviceUrl() ~ "/ping");
            return response.success;
        } catch (Exception) {
            return false;
        }
    }

    SAPIDocResponse submit(SAPIDocSubmitRequest request) {
        if (request.control.idocType.length == 0) {
            throw new SAPIDocRequestException("IDOC type cannot be empty");
        }

        if (request.control.messageType.length == 0) {
            throw new SAPIDocRequestException("Message type cannot be empty");
        }

        auto response = requestJSON(
            HTTPMethod.POST,
            _config.serviceUrl() ~ "/inbound",
            request.toJson()
        );

        if ("documentNumber" in response.data && response.data["documentNumber"].type == Json.Type.string) {
            response.documentNumber = response.data["documentNumber"].get!string;
        }

        if ("status" in response.data && response.data["status"].type == Json.Type.string) {
            response.status = response.data["status"].get!string;
        }

        return response;
    }

    SAPIDocResponse submit(
        string idocType,
        string messageType,
        Json segments,
        string senderPort = "",
        string receiverPort = "",
        bool testRun = false
    ) {
        SAPIDocSubmitRequest request;
        request.control.idocType = idocType;
        request.control.messageType = messageType;
        request.control.senderPort = senderPort;
        request.control.receiverPort = receiverPort;
        request.segments = segments;
        request.testRun = testRun;

        return submit(request);
    }

    SAPIDocResponse getStatus(string documentNumber) {
        if (documentNumber.length == 0) {
            throw new SAPIDocRequestException("Document number cannot be empty");
        }

        auto url = _config.serviceUrl() ~ "/status/" ~ urlEncode(documentNumber);
        auto response = requestJSON(HTTPMethod.GET, url);

        response.documentNumber = documentNumber;
        if ("status" in response.data && response.data["status"].type == Json.Type.string) {
            response.status = response.data["status"].get!string;
        }

        return response;
    }

    private SAPIDocResponse requestJSON(HTTPMethod method, string url, Json body = Json.emptyObject) {
        uint attempts = 0;

        while (attempts <= _config.maxRetries) {
            try {
                SAPIDocResponse response;
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
                            req.writeJsonBody(body);
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
                            if ("error" in response.data && response.data["error"].type == Json.Type.string) {
                                response.errorMessage = response.data["error"].get!string;
                            } else {
                                response.errorMessage = format(
                                    "SAP IDOC request failed with status code %d",
                                    response.statusCode
                                );
                            }
                        }
                    }
                );

                if (!response.success) {
                    throw new SAPIDocRequestException(response.errorMessage, response.statusCode);
                }

                return response;
            } catch (SAPIDocRequestException e) {
                throw e;
            } catch (Exception e) {
                attempts++;
                if (attempts > _config.maxRetries) {
                    throw new SAPIDocConnectionException(
                        format("SAP IDOC request failed after %d retries: %s", attempts, e.msg)
                    );
                }
            }
        }

        throw new SAPIDocConnectionException("SAP IDOC request failed with unknown error");
    }

    private void applyAuth(HTTPClientRequest req) {
        final switch (_config.authType) {
            case SAPIDocAuthType.None:
                break;
            case SAPIDocAuthType.Basic:
                auto creds = _config.username ~ ":" ~ _config.password;
                auto token = Base64.encode(cast(const(ubyte)[])creds).idup;
                req.headers["Authorization"] = "Basic " ~ token;
                break;
            case SAPIDocAuthType.Bearer:
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
