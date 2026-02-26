module uim.sap.mgt.server;

import uim.sap.mgt;

mixin(ShowModule!());

@safe:

class MGTServer {
    private MGTService _service;

    this(MGTService service) {
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
            validateAuth(req);

            if (subPath == "/v1/environments" && req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.environments(), 200);
                return;
            }
            if (subPath == "/v1/subaccounts" && req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.subaccounts(), 200);
                return;
            }
            if (subPath == "/v1/organizations" && req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.organizations(), 200);
                return;
            }
            if (subPath == "/v1/spaces" && req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.spaces(), 200);
                return;
            }
            if (subPath == "/v1/applications" && req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.applications(), 200);
                return;
            }
            if (subPath.startsWith("/v1/applications/") && req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.application(lastSegment(subPath)), 200);
                return;
            }
            if (subPath == "/v1/services" && req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.services(), 200);
                return;
            }
            if (subPath == "/v1/service_instances" && req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.serviceInstances(), 200);
                return;
            }
            if (subPath == "/v1/destinations" && req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.destinations(), 200);
                return;
            }
            if (subPath.startsWith("/v1/destinations/") && req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.destination(lastSegment(subPath)), 200);
                return;
            }

            respondError(res, "Not found", 404);
        } catch (MGTAuthorizationException e) {
            respondError(res, e.msg, 401);
        } catch (MGTUpstreamException e) {
            respondError(res, e.msg, 502);
        } catch (MGTException e) {
            respondError(res, e.msg, 500);
        } catch (Exception e) {
            respondError(res, e.msg, 500);
        }
    }

    private void validateAuth(HTTPServerRequest req) {
        if (!_service.config.requireAuthToken) {
            return;
        }

        if (!("Authorization" in req.headers)) {
            throw new MGTAuthorizationException("Missing Authorization header");
        }

        auto expected = "Bearer " ~ _service.config.authToken;
        if (req.headers["Authorization"] != expected) {
            throw new MGTAuthorizationException("Invalid token");
        }
    }

    private string lastSegment(string path) {
        auto parts = path.split("/");
        if (parts.length == 0) {
            return "";
        }
        return parts[$ - 1];
    }

    private void respondError(HTTPServerResponse res, string message, int statusCode) {
        Json payload = Json.emptyObject;
        payload["success"] = false;
        payload["message"] = message;
        payload["statusCode"] = statusCode;
        res.writeJsonBody(payload, statusCode);
    }
}
