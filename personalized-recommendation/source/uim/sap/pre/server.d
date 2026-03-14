/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.pre.server;

import uim.sap.pre;

mixin(ShowModule!());
@safe:

class PREServer {
    private PREService _service;

    this(PREService service) {
        _service = service;
    }

    void run() {
        auto settings = new HTTPServerSettings;
        settings.port = _service.config.port;
        settings.bindAddresses = [_service.config.host];
        listenHTTP(settings, &handleRequest);
        runApplication();
    }

    private void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
        foreach (key, value; _service.config.customHeaders)
            res.headers[key] = value;

        auto basePath = _service.config.basePath;
        auto path = req.path;

        if (!path.startsWith(basePath)) {
            respondError(res, "Not found", 404);
            return;
        }

        auto subPath = path[basePath.length .. $];
        if (subPath.length == 0)
            subPath = "/";

        // Health / ready
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

            // /v1/tenants/...
            if (segments.length >= 2 && segments[0] == "v1" && segments[1] == "tenants") {
                routeTenants(req, res, segments[2 .. $]);
                return;
            }

            respondError(res, "Not found", 404);
        } catch (PREAuthorizationException e) {
            respondError(res, e.msg, 401);
        } catch (PREConflictException e) {
            respondError(res, e.msg, 409);
        } catch (PRENotFoundException e) {
            respondError(res, e.msg, 404);
        } catch (PREValidationException e) {
            respondError(res, e.msg, 400);
        } catch (PREQuotaExceededException e) {
            respondError(res, e.msg, 429);
        } catch (PREConfigurationException e) {
            respondError(res, e.msg, 500);
        } catch (PREException e) {
            respondError(res, e.msg, 500);
        } catch (Exception e) {
            respondError(res, "Internal server error", 500);
        }
    }

    // ──────── Tenant Router ────────

    private void routeTenants(HTTPServerRequest req, HTTPServerResponse res, string[] rest) {
        if (rest.length == 0) {
            respondError(res, "Tenant ID required", 400);
            return;
        }

        string tenantId = rest[0];

        // /v1/tenants/{tid}/items...
        if (rest.length >= 2 && rest[1] == "items") {
            routeItems(req, res, tenantId, rest[2 .. $]);
            return;
        }

        // /v1/tenants/{tid}/users...
        if (rest.length >= 2 && rest[1] == "users") {
            routeUsers(req, res, tenantId, rest[2 .. $]);
            return;
        }

        // /v1/tenants/{tid}/interactions...
        if (rest.length >= 2 && rest[1] == "interactions") {
            routeInteractions(req, res, tenantId, rest[2 .. $]);
            return;
        }

        // /v1/tenants/{tid}/models...
        if (rest.length >= 2 && rest[1] == "models") {
            routeModels(req, res, tenantId, rest[2 .. $]);
            return;
        }

        // /v1/tenants/{tid}/scenarios...
        if (rest.length >= 2 && rest[1] == "scenarios") {
            routeScenarios(req, res, tenantId, rest[2 .. $]);
            return;
        }

        // /v1/tenants/{tid}/recommend...
        if (rest.length >= 2 && rest[1] == "recommend") {
            routeRecommend(req, res, tenantId, rest[2 .. $]);
            return;
        }

        respondError(res, "Not found", 404);
    }

    // ──────── Item Routes ────────

    private void routeItems(HTTPServerRequest req, HTTPServerResponse res,
            string tenantId, string[] rest) {
        // GET|POST /v1/tenants/{tid}/items
        if (rest.length == 0) {
            if (req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.listItems(tenantId), 200);
                return;
            }
            if (req.method == HTTPMethod.POST) {
                res.writeJsonBody(_service.addItem(tenantId, parseBody(req)), 201);
                return;
            }
            respondError(res, "Method not allowed", 405);
            return;
        }

        string itemId = rest[0];

        // GET|PUT|DELETE /v1/tenants/{tid}/items/{itemId}
        if (rest.length == 1) {
            if (req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.getItem(tenantId, itemId), 200);
                return;
            }
            if (req.method == HTTPMethod.PUT) {
                res.writeJsonBody(_service.updateItem(tenantId, itemId, parseBody(req)), 200);
                return;
            }
            if (req.method == HTTPMethod.DELETE) {
                res.writeJsonBody(_service.deleteItem(tenantId, itemId), 200);
                return;
            }
            respondError(res, "Method not allowed", 405);
            return;
        }

        // GET /v1/tenants/{tid}/items/{itemId}/interactions
        if (rest.length == 2 && rest[1] == "interactions" && req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listItemInteractions(tenantId, itemId), 200);
            return;
        }

        respondError(res, "Not found", 404);
    }

    // ──────── User Routes ────────

    private void routeUsers(HTTPServerRequest req, HTTPServerResponse res,
            string tenantId, string[] rest) {
        // GET|POST /v1/tenants/{tid}/users
        if (rest.length == 0) {
            if (req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.listUsers(tenantId), 200);
                return;
            }
            if (req.method == HTTPMethod.POST) {
                res.writeJsonBody(_service.registerUser(tenantId, parseBody(req)), 201);
                return;
            }
            respondError(res, "Method not allowed", 405);
            return;
        }

        string userId = rest[0];

        // GET|PUT|DELETE /v1/tenants/{tid}/users/{userId}
        if (rest.length == 1) {
            if (req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.getUser(tenantId, userId), 200);
                return;
            }
            if (req.method == HTTPMethod.PUT) {
                res.writeJsonBody(_service.updateUser(tenantId, userId, parseBody(req)), 200);
                return;
            }
            if (req.method == HTTPMethod.DELETE) {
                res.writeJsonBody(_service.deleteUser(tenantId, userId), 200);
                return;
            }
            respondError(res, "Method not allowed", 405);
            return;
        }

        // GET /v1/tenants/{tid}/users/{userId}/interactions
        if (rest.length == 2 && rest[1] == "interactions" && req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listUserInteractions(tenantId, userId), 200);
            return;
        }

        respondError(res, "Not found", 404);
    }

    // ──────── Interaction Routes ────────

    private void routeInteractions(HTTPServerRequest req, HTTPServerResponse res,
            string tenantId, string[] rest) {
        // POST /v1/tenants/{tid}/interactions
        if (rest.length == 0 && req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.recordInteraction(tenantId, parseBody(req)), 201);
            return;
        }
        respondError(res, "Not found", 404);
    }

    // ──────── Model Routes ────────

    private void routeModels(HTTPServerRequest req, HTTPServerResponse res,
            string tenantId, string[] rest) {
        // GET|POST /v1/tenants/{tid}/models
        if (rest.length == 0) {
            if (req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.listModels(tenantId), 200);
                return;
            }
            if (req.method == HTTPMethod.POST) {
                res.writeJsonBody(_service.createModel(tenantId, parseBody(req)), 201);
                return;
            }
            respondError(res, "Method not allowed", 405);
            return;
        }

        string modelId = rest[0];

        // GET|DELETE /v1/tenants/{tid}/models/{modelId}
        if (rest.length == 1) {
            if (req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.getModel(tenantId, modelId), 200);
                return;
            }
            if (req.method == HTTPMethod.DELETE) {
                res.writeJsonBody(_service.deleteModel(tenantId, modelId), 200);
                return;
            }
            respondError(res, "Method not allowed", 405);
            return;
        }

        // POST /v1/tenants/{tid}/models/{modelId}/train
        if (rest.length == 2 && rest[1] == "train" && req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.trainModel(tenantId, modelId), 200);
            return;
        }

        // GET /v1/tenants/{tid}/models/{modelId}/jobs
        if (rest.length == 2 && rest[1] == "jobs" && req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listTrainingJobs(tenantId, modelId), 200);
            return;
        }

        respondError(res, "Not found", 404);
    }

    // ──────── Scenario Routes ────────

    private void routeScenarios(HTTPServerRequest req, HTTPServerResponse res,
            string tenantId, string[] rest) {
        // GET|POST /v1/tenants/{tid}/scenarios
        if (rest.length == 0) {
            if (req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.listScenarios(tenantId), 200);
                return;
            }
            if (req.method == HTTPMethod.POST) {
                res.writeJsonBody(_service.createScenario(tenantId, parseBody(req)), 201);
                return;
            }
            respondError(res, "Method not allowed", 405);
            return;
        }

        string scenarioId = rest[0];

        // GET|DELETE /v1/tenants/{tid}/scenarios/{sid}
        if (rest.length == 1) {
            if (req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.getScenario(tenantId, scenarioId), 200);
                return;
            }
            if (req.method == HTTPMethod.DELETE) {
                res.writeJsonBody(_service.deleteScenario(tenantId, scenarioId), 200);
                return;
            }
            respondError(res, "Method not allowed", 405);
            return;
        }

        respondError(res, "Not found", 404);
    }

    // ──────── Recommendation Routes ────────

    private void routeRecommend(HTTPServerRequest req, HTTPServerResponse res,
            string tenantId, string[] rest) {
        if (rest.length == 0 || req.method != HTTPMethod.GET) {
            respondError(res, "Not found", 404);
            return;
        }

        auto modelId = req.params.get("modelId", "");
        size_t limit = 0;
        auto limitStr = req.params.get("limit", "0");
        try {
            import std.conv : to;
            limit = limitStr.to!size_t;
        } catch (Exception) {
            limit = 0;
        }

        switch (rest[0]) {
            // GET /v1/tenants/{tid}/recommend/next-item?userId=...&modelId=...&limit=...
            case "next-item":
                auto userId = req.params.get("userId", "");
                if (userId.length == 0 || modelId.length == 0) {
                    respondError(res, "userId and modelId are required", 400);
                    return;
                }
                res.writeJsonBody(
                    _service.getNextItemRecommendations(tenantId, userId, modelId, limit), 200);
                return;

            // GET /v1/tenants/{tid}/recommend/similar-item?itemId=...&modelId=...&limit=...
            case "similar-item":
                auto itemId = req.params.get("itemId", "");
                if (itemId.length == 0 || modelId.length == 0) {
                    respondError(res, "itemId and modelId are required", 400);
                    return;
                }
                res.writeJsonBody(
                    _service.getSimilarItemRecommendations(tenantId, itemId, modelId, limit), 200);
                return;

            // GET /v1/tenants/{tid}/recommend/smart-search?userId=...&q=...&modelId=...&limit=...
            case "smart-search":
                auto userId = req.params.get("userId", "");
                auto q = req.params.get("q", "");
                if (modelId.length == 0) {
                    respondError(res, "modelId is required", 400);
                    return;
                }
                res.writeJsonBody(
                    _service.getSmartSearchResults(tenantId, userId, q, modelId, limit), 200);
                return;

            // GET /v1/tenants/{tid}/recommend/user-affinity?userId=...&modelId=...&limit=...
            case "user-affinity":
                auto userId = req.params.get("userId", "");
                if (userId.length == 0 || modelId.length == 0) {
                    respondError(res, "userId and modelId are required", 400);
                    return;
                }
                res.writeJsonBody(
                    _service.getUserAffinityRecommendations(tenantId, userId, modelId, limit), 200);
                return;

            default:
                break;
        }

        respondError(res, "Not found", 404);
    }

    // ──────── Helpers ────────

    private void validateAuth(HTTPServerRequest req) {
        if (!_service.config.requireAuthToken)
            return;
        auto authHeader = req.headers.get("Authorization", "");
        if (!authHeader.startsWith("Bearer "))
            throw new PREAuthorizationException("Missing bearer token");
        auto token = authHeader[7 .. $];
        if (token != _service.config.authToken)
            throw new PREAuthorizationException("Invalid bearer token");
    }

    private static string[] normalizedSegments(string path) {
        import std.algorithm : filter;
        import std.array : array;
        return path.split("/").filter!(s => s.length > 0).array;
    }

    private static Json parseBody(HTTPServerRequest req) {
        try {
            return req.readJson();
        } catch (Exception) {
            return Json.emptyObject;
        }
    }

    private static void respondError(HTTPServerResponse res, string message, int code) {
        Json j = Json.emptyObject;
        j["error"] = message;
        j["code"] = code;
        res.writeJsonBody(j, code);
    }
}
