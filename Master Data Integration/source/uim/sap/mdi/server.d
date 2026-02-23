module uim.sap.mdi.server;

import std.array : split;
import std.string : startsWith;

import vibe.data.json : Json;
import vibe.http.common : HTTPMethod;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse, HTTPServerSettings, listenHTTP;

import uim.sap.mdi.exceptions;
import uim.sap.mdi.service;

class MDIServer {
    private MDIService _service;

    this(MDIService service) {
        _service = service;
    }

    void run() {
        HTTPServerSettings settings;
        settings.port = _service.config.port;
        settings.bindAddresses = [_service.config.host];
        listenHTTP(settings, &handleRequest);
    }

    private void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
        foreach (key, value; _service.config.customHeaders) res.headers[key] = value;

        auto basePath = _service.config.basePath;
        auto path = req.path;
        if (!path.startsWith(basePath)) {
            respondError(res, "Not found", 404);
            return;
        }

        auto subPath = path[basePath.length .. $];
        if (subPath.length == 0) subPath = "/";

        if (subPath == "/health" && req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.health(), 200);
            return;
        }

        if (subPath == "/ready" && req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.ready(), 200);
            return;
        }

        try {
            validateAuth(req);
            auto segments = normalizedSegments(subPath);

            if (segments.length >= 3 && segments[0] == "v1" && segments[1] == "tenants") {
                auto tenantId = segments[2];

                if (segments.length == 4 && segments[3] == "clients") {
                    if (req.method == HTTPMethod.GET) {
                        res.writeJsonBody(_service.listClients(tenantId), 200);
                        return;
                    }
                    if (req.method == HTTPMethod.POST) {
                        res.writeJsonBody(_service.upsertClient(tenantId, req.json), 200);
                        return;
                    }
                }

                if (segments.length == 5 && segments[3] == "filters") {
                    auto filterId = segments[4];
                    if (req.method == HTTPMethod.PUT) {
                        res.writeJsonBody(_service.upsertFilter(tenantId, filterId, req.json), 200);
                        return;
                    }
                }

                if (segments.length == 4 && segments[3] == "filters" && req.method == HTTPMethod.GET) {
                    res.writeJsonBody(_service.listFilters(tenantId), 200);
                    return;
                }

                if (segments.length == 5 && segments[3] == "extensions") {
                    auto extensionId = segments[4];
                    if (req.method == HTTPMethod.PUT) {
                        res.writeJsonBody(_service.upsertExtension(tenantId, extensionId, req.json), 200);
                        return;
                    }
                }

                if (segments.length == 4 && segments[3] == "extensions" && req.method == HTTPMethod.GET) {
                    res.writeJsonBody(_service.listExtensions(tenantId), 200);
                    return;
                }

                if (segments.length == 5 && segments[3] == "replication" && segments[4] == "run" && req.method == HTTPMethod.POST) {
                    res.writeJsonBody(_service.replicate(tenantId, req.json), 200);
                    return;
                }

                if (segments.length == 5 && segments[3] == "replication" && segments[4] == "jobs" && req.method == HTTPMethod.GET) {
                    res.writeJsonBody(_service.listReplications(tenantId), 200);
                    return;
                }
            }

            respondError(res, "Not found", 404);
        } catch (MDIAuthorizationException e) {
            respondError(res, e.msg, 401);
        } catch (MDINotFoundException e) {
            respondError(res, e.msg, 404);
        } catch (MDIValidationException e) {
            respondError(res, e.msg, 422);
        } catch (MDIException e) {
            respondError(res, e.msg, 500);
        } catch (Exception e) {
            respondError(res, e.msg, 500);
        }
    }

    private void validateAuth(HTTPServerRequest req) {
        if (!_service.config.requireAuthToken) return;
        if (!("Authorization" in req.headers)) throw new MDIAuthorizationException("Missing Authorization header");
        auto expected = "Bearer " ~ _service.config.authToken;
        if (req.headers["Authorization"] != expected) throw new MDIAuthorizationException("Invalid token");
    }

    private string[] normalizedSegments(string subPath) {
        auto clean = subPath;
        if (clean.length > 0 && clean[0] == '/') clean = clean[1 .. $];
        if (clean.length > 0 && clean[$ - 1] == '/') clean = clean[0 .. $ - 1];
        if (clean.length == 0) return [];
        return clean.split("/");
    }

    private void respondError(HTTPServerResponse res, string message, int statusCode) {
        Json payload = Json.emptyObject;
        payload["success"] = false;
        payload["message"] = message;
        payload["statusCode"] = statusCode;
        res.writeJsonBody(payload, statusCode);
    }
}
