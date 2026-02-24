module uim.sap.atm.server;

import std.array : split;
import std.string : startsWith;

import vibe.data.json : Json;
import vibe.http.common : HTTPMethod;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse, HTTPServerSettings, listenHTTP;

import uim.sap.atm.exceptions;
import uim.sap.atm.service;

class ATMServer {
    private ATMService _service;

    this(ATMService service) {
        _service = service;
    }

    void run() {
        HTTPServerSettings settings;
        settings.port = _service.config.port;
        settings.bindAddresses = [_service.config.host];
        listenHTTP(settings, &handleRequest);
    }

    private void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
        foreach (key, value; _service.config.customHeaders) {
            res.headers[key] = value;
        }

        auto basePath = _service.config.basePath;
        auto path = req.path;

        if (!path.startsWith(basePath)) {
            respondError(res, "Not found", 404);
            return;
        }

        auto subPath = path[basePath.length .. $];
        if (subPath.length == 0) {
            subPath = "/";
        }

        if (subPath == "/health" && req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.health(), 200);
            return;
        }

        if (subPath == "/ready" && req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.ready(), 200);
            return;
        }

        try {
            auto segments = normalizedSegments(subPath);
            if (segments.length < 3 || segments[0] != "v1" || segments[1] != "tenants") {
                respondError(res, "Not found", 404);
                return;
            }

            auto tenantId = segments[2];

            if (segments.length == 4 && segments[3] == "auth" && req.method == HTTPMethod.GET) {
                auto context = resolveContext(req, tenantId);
                res.writeJsonBody(_service.currentSession(context), 200);
                return;
            }

            if (segments.length == 4 && segments[3] == "idps") {
                auto context = resolveContext(req, tenantId);
                requirePermission(context, "iam.admin");
                if (req.method == HTTPMethod.GET) {
                    res.writeJsonBody(_service.listIdentityProviders(tenantId), 200);
                    return;
                }
            }

            if (segments.length == 5 && segments[3] == "idps" && req.method == HTTPMethod.PUT) {
                auto context = resolveContext(req, tenantId);
                requirePermission(context, "iam.admin");
                res.writeJsonBody(_service.upsertIdentityProvider(tenantId, segments[4], req.json), 200);
                return;
            }

            if (segments.length == 6
                && segments[3] == "idps"
                && segments[5] == "default"
                && req.method == HTTPMethod.POST) {
                auto context = resolveContext(req, tenantId);
                requirePermission(context, "iam.admin");
                res.writeJsonBody(_service.setDefaultIdentityProvider(tenantId, segments[4]), 200);
                return;
            }

            if (segments.length == 5 && segments[3] == "roles" && segments[4] == "technical") {
                auto context = resolveContext(req, tenantId);
                requirePermission(context, "iam.admin");
                if (req.method == HTTPMethod.GET) {
                    res.writeJsonBody(_service.listTechnicalRoles(tenantId), 200);
                    return;
                }
            }

            if (segments.length == 6 && segments[3] == "roles" && segments[4] == "technical" && req.method == HTTPMethod.PUT) {
                auto context = resolveContext(req, tenantId);
                requirePermission(context, "iam.admin");
                res.writeJsonBody(_service.upsertTechnicalRole(tenantId, segments[5], req.json), 200);
                return;
            }

            if (segments.length == 4 && segments[3] == "role-collections") {
                auto context = resolveContext(req, tenantId);
                requirePermission(context, "iam.admin");
                if (req.method == HTTPMethod.GET) {
                    res.writeJsonBody(_service.listRoleCollections(tenantId), 200);
                    return;
                }
            }

            if (segments.length == 5 && segments[3] == "role-collections" && req.method == HTTPMethod.PUT) {
                auto context = resolveContext(req, tenantId);
                requirePermission(context, "iam.admin");
                res.writeJsonBody(_service.upsertRoleCollection(tenantId, segments[4], req.json), 200);
                return;
            }

            if (segments.length == 6 && segments[3] == "users" && segments[5] == "assignments") {
                auto context = resolveContext(req, tenantId);
                requirePermission(context, "iam.admin");
                if (req.method == HTTPMethod.GET) {
                    res.writeJsonBody(_service.getUserAssignments(tenantId, segments[4]), 200);
                    return;
                }
                if (req.method == HTTPMethod.PUT) {
                    res.writeJsonBody(_service.upsertUserAssignments(tenantId, segments[4], req.json), 200);
                    return;
                }
            }

            if (segments.length == 6 && segments[3] == "apps" && segments[5] == "authorize" && req.method == HTTPMethod.POST) {
                auto context = resolveContext(req, tenantId);
                res.writeJsonBody(_service.authorizeApplication(tenantId, context, segments[4], req.json), 200);
                return;
            }

            respondError(res, "Not found", 404);
        } catch (ATMAuthorizationException e) {
            respondError(res, e.msg, 401);
        } catch (ATMNotFoundException e) {
            respondError(res, e.msg, 404);
        } catch (ATMValidationException e) {
            respondError(res, e.msg, 422);
        } catch (ATMException e) {
            respondError(res, e.msg, 500);
        } catch (Exception e) {
            respondError(res, e.msg, 500);
        }
    }

    private ATMSessionContext resolveContext(HTTPServerRequest req, string tenantId) {
        if (_service.config.bootstrapToken.length > 0) {
            if ("X-Bootstrap-Token" in req.headers && req.headers["X-Bootstrap-Token"] == _service.config.bootstrapToken) {
                return _service.bootstrapContext(tenantId);
            }
        }

        if (!("Authorization" in req.headers)) {
            throw new ATMAuthorizationException("Missing Authorization header");
        }
        return _service.authenticateBearer(tenantId, req.headers["Authorization"]);
    }

    private void requirePermission(ATMSessionContext context, string permission) {
        if (!_service.hasPermission(context, permission)) {
            throw new ATMAuthorizationException("Missing required permission: " ~ permission);
        }
    }

    private string[] normalizedSegments(string subPath) {
        auto clean = subPath;
        if (clean.length > 0 && clean[0] == '/') {
            clean = clean[1 .. $];
        }
        if (clean.length > 0 && clean[$ - 1] == '/') {
            clean = clean[0 .. $ - 1];
        }
        if (clean.length == 0) {
            return [];
        }
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
