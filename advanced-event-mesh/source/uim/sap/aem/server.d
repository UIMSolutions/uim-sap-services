module uim.sap.aem.server;


import uim.sap.aem;

mixin(ShowModule!());

@safe:



class AEMServer {
    private AEMService _service;

    this(AEMService service) {
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

            auto segments = normalizedSegments(subPath);
            if (segments.length >= 3 && segments[0] == "v1" && segments[1] == "tenants") {
                auto tenantId = segments[2];

                if (segments.length == 4 && segments[3] == "broker-services") {
                    if (req.method == HTTPMethod.GET) {
                        res.writeJsonBody(_service.listBrokerServices(tenantId), 200);
                        return;
                    }
                    if (req.method == HTTPMethod.POST) {
                        res.writeJsonBody(_service.createBrokerService(tenantId, req.json), 200);
                        return;
                    }
                }

                if (segments.length == 6
                    && segments[3] == "broker-services"
                    && segments[5] == "event-meshes"
                    && req.method == HTTPMethod.POST) {
                    res.writeJsonBody(_service.createEventMesh(tenantId, segments[4], req.json), 200);
                    return;
                }

                if (segments.length == 4 && segments[3] == "event-meshes" && req.method == HTTPMethod.GET) {
                    res.writeJsonBody(_service.listEventMeshes(tenantId), 200);
                    return;
                }

                if (segments.length == 6
                    && segments[3] == "event-meshes"
                    && segments[5] == "topics"
                    && req.method == HTTPMethod.POST) {
                    res.writeJsonBody(_service.registerTopic(tenantId, segments[4], req.json), 200);
                    return;
                }

                if (segments.length == 6
                    && segments[3] == "event-meshes"
                    && segments[5] == "publish"
                    && req.method == HTTPMethod.POST) {
                    res.writeJsonBody(_service.publishEvent(tenantId, segments[4], req.json), 200);
                    return;
                }

                if (segments.length == 8
                    && segments[3] == "event-meshes"
                    && segments[5] == "topics"
                    && segments[7] == "events"
                    && req.method == HTTPMethod.GET) {
                    auto meshId = segments[4];
                    auto topic = segments[6];
                    res.writeJsonBody(_service.listTopicEvents(tenantId, meshId, topic), 200);
                    return;
                }

                if (segments.length == 4 && segments[3] == "components") {
                    if (req.method == HTTPMethod.GET) {
                        res.writeJsonBody(_service.listComponents(tenantId), 200);
                        return;
                    }
                    if (req.method == HTTPMethod.POST) {
                        res.writeJsonBody(_service.upsertComponent(tenantId, req.json), 200);
                        return;
                    }
                }

                if (segments.length == 6
                    && segments[3] == "components"
                    && segments[5] == "subscriptions"
                    && req.method == HTTPMethod.POST) {
                    res.writeJsonBody(_service.addSubscription(tenantId, segments[4], req.json), 200);
                    return;
                }

                if (segments.length == 5
                    && segments[3] == "eda"
                    && segments[4] == "model"
                    && req.method == HTTPMethod.GET) {
                    res.writeJsonBody(_service.modelEDA(tenantId), 200);
                    return;
                }

                if (segments.length == 5
                    && segments[3] == "monitoring"
                    && segments[4] == "dashboard"
                    && req.method == HTTPMethod.GET) {
                    res.writeJsonBody(_service.monitoringDashboard(tenantId), 200);
                    return;
                }

                if (segments.length == 5
                    && segments[3] == "monitoring"
                    && segments[4] == "alerts"
                    && req.method == HTTPMethod.GET) {
                    res.writeJsonBody(_service.listAlerts(tenantId), 200);
                    return;
                }

                if (segments.length == 5
                    && segments[3] == "monitoring"
                    && segments[4] == "notifications"
                    && req.method == HTTPMethod.GET) {
                    res.writeJsonBody(_service.listNotificationRules(tenantId), 200);
                    return;
                }

                if (segments.length == 6
                    && segments[3] == "monitoring"
                    && segments[4] == "notifications"
                    && req.method == HTTPMethod.PUT) {
                    auto ruleId = segments[5];
                    res.writeJsonBody(_service.upsertNotificationRule(tenantId, ruleId, req.json), 200);
                    return;
                }
            }

            respondError(res, "Not found", 404);
        } catch (AEMAuthorizationException e) {
            respondError(res, e.msg, 401);
        } catch (AEMNotFoundException e) {
            respondError(res, e.msg, 404);
        } catch (AEMValidationException e) {
            respondError(res, e.msg, 422);
        } catch (AEMException e) {
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
            throw new AEMAuthorizationException("Missing Authorization header");
        }

        auto expected = "Bearer " ~ _service.config.authToken;
        if (req.headers["Authorization"] != expected) {
            throw new AEMAuthorizationException("Invalid token");
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
