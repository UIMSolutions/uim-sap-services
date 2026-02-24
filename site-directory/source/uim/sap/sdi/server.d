module uim.sap.sdi.server;

import std.array : split;
import std.string : startsWith;

import vibe.data.json : Json;
import vibe.http.common : HTTPMethod;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse, HTTPServerSettings, listenHTTP;

import uim.sap.sdi.exceptions;
import uim.sap.sdi.service;

class SDIServer {
    private SDIService _service;

    this(SDIService service) {
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

                if (segments.length == 4 && segments[3] == "sites") {
                    if (req.method == HTTPMethod.GET) {
                        res.writeJsonBody(_service.listSiteTiles(tenantId), 200);
                        return;
                    }
                    if (req.method == HTTPMethod.POST) {
                        res.writeJsonBody(_service.createSite(tenantId, req.json), 200);
                        return;
                    }
                }

                if (segments.length == 5 && segments[3] == "sites") {
                    auto siteId = segments[4];
                    if (req.method == HTTPMethod.GET) {
                        res.writeJsonBody(_service.getSite(tenantId, siteId), 200);
                        return;
                    }
                    if (req.method == HTTPMethod.DELETE) {
                        res.writeJsonBody(_service.deleteSite(tenantId, siteId), 200);
                        return;
                    }
                }

                if (segments.length == 6 && segments[3] == "sites") {
                    auto siteId = segments[4];
                    auto action = segments[5];

                    if (action == "import" && req.method == HTTPMethod.POST) {
                        res.writeJsonBody(_service.importSite(tenantId, siteId, req.json), 200);
                        return;
                    }
                    if (action == "export" && req.method == HTTPMethod.GET) {
                        res.writeJsonBody(_service.exportSite(tenantId, siteId), 200);
                        return;
                    }
                    if (action == "alias" && req.method == HTTPMethod.PUT) {
                        res.writeJsonBody(_service.updateAlias(tenantId, siteId, req.json), 200);
                        return;
                    }
                    if (action == "default" && req.method == HTTPMethod.PUT) {
                        res.writeJsonBody(_service.setDefaultSite(tenantId, siteId), 200);
                        return;
                    }
                    if (action == "settings") {
                        if (req.method == HTTPMethod.GET) {
                            res.writeJsonBody(_service.getSiteSettings(tenantId, siteId), 200);
                            return;
                        }
                        if (req.method == HTTPMethod.PUT) {
                            res.writeJsonBody(_service.updateSiteSettings(tenantId, siteId, req.json), 200);
                            return;
                        }
                    }
                    if (action == "roles" && req.method == HTTPMethod.PUT) {
                        res.writeJsonBody(_service.assignRoles(tenantId, siteId, req.json), 200);
                        return;
                    }
                }

                if (segments.length == 7 && segments[3] == "sites" && segments[5] == "runtime" && segments[6] == "open" && req.method == HTTPMethod.POST) {
                    auto siteId = segments[4];
                    res.writeJsonBody(_service.openRuntimeSite(tenantId, siteId), 200);
                    return;
                }
            }

            respondError(res, "Not found", 404);
        } catch (SDIAuthorizationException e) {
            respondError(res, e.msg, 401);
        } catch (SDINotFoundException e) {
            respondError(res, e.msg, 404);
        } catch (SDIValidationException e) {
            respondError(res, e.msg, 422);
        } catch (SDIException e) {
            respondError(res, e.msg, 500);
        } catch (Exception e) {
            respondError(res, e.msg, 500);
        }
    }

    private void validateAuth(HTTPServerRequest req) {
        if (!_service.config.requireAuthToken) return;
        if (!("Authorization" in req.headers)) throw new SDIAuthorizationException("Missing Authorization header");
        auto expected = "Bearer " ~ _service.config.authToken;
        if (req.headers["Authorization"] != expected) throw new SDIAuthorizationException("Invalid token");
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
