module uim.sap.cia.server;

import uim.sap.cia;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// CIAServer – Vibe.D HTTP server wiring all CIA API routes
// ---------------------------------------------------------------------------
class CIAServer {
    private CIAService _service;

    this(CIAService service) {
        _service = service;
    }

    override void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
        // Inject configured custom headers on every response
        foreach (key, value; _service.config.customHeaders)
            res.headers[key] = value;

        auto basePath = _service.config.basePath;
        auto path     = req.path;

        if (!path.startsWith(basePath)) {
            respondError(res, "Not found", 404);
            return;
        }

        auto subPath = path[basePath.length .. $];
        if (subPath.length == 0)
            subPath = "/";

        // ── Root dashboard ────────────────────────────────────────────────
        if (subPath == "/" && req.method == HTTPMethod.GET) {
            res.contentType = "text/html; charset=utf-8";
            res.writeBody(_service.dashboardHtml());
            return;
        }

        // ── Health / readiness probes ─────────────────────────────────────
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
            route(req, res, subPath);
        }
        catch (CIANotFoundException e) {
            respondError(res, e.msg, 404);
        }
        catch (CIAValidationException e) {
            respondError(res, e.msg, 400);
        }
        catch (CIAAuthorizationException e) {
            respondError(res, e.msg, 403);
        }
        catch (CIAWorkflowStateException e) {
            respondError(res, e.msg, 409);
        }
        catch (CIAAutomationException e) {
            respondError(res, e.msg, 422);
        }
        catch (CIAException e) {
            respondError(res, e.msg, 500);
        }
    }

    private void route(HTTPServerRequest req, HTTPServerResponse res, string subPath) {
        auto segs = normalizedSegments(subPath);

        // ── v1/roles  (global) ────────────────────────────────────────────
        if (segs.length == 2 && segs[0] == "v1" && segs[1] == "roles") {
            if (req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.listRoles(), 200);
                return;
            }
            if (req.method == HTTPMethod.POST) {
                res.writeJsonBody(_service.upsertRole(req.json), 200);
                return;
            }
        }

        // ── v1/scenarios  (global, template library) ─────────────────────
        if (segs.length == 2 && segs[0] == "v1" && segs[1] == "scenarios") {
            if (req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.listScenarios(), 200);
                return;
            }
        }
        if (segs.length == 3 && segs[0] == "v1" && segs[1] == "scenarios") {
            if (req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.getScenario(UUID(segs[2])), 200);
                return;
            }
        }

        // All remaining routes are tenant-scoped: /v1/tenants/:tenantId/…
        if (segs.length < 3 || segs[0] != "v1" || segs[1] != "tenants") {
            respondError(res, "Not found", 404);
            return;
        }
        auto tenantId = UUID(segs[2]);

        // ── /systems ──────────────────────────────────────────────────────
        if (segs.length == 4 && segs[3] == "systems") {
            if (req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.listSystems(tenantId), 200);
                return;
            }
            if (req.method == HTTPMethod.POST) {
                res.writeJsonBody(_service.upsertSystem(tenantId, req.json), 201);
                return;
            }
        }
        if (segs.length == 5 && segs[3] == "systems") {
            if (req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.getSystem(tenantId, UUID(segs[4])), 200);
                return;
            }
        }

        // ── /workflows ────────────────────────────────────────────────────
        if (segs.length == 4 && segs[3] == "workflows") {
            if (req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.listWorkflows(tenantId), 200);
                return;
            }
            if (req.method == HTTPMethod.POST) {
                res.writeJsonBody(_service.planWorkflow(tenantId, req.json), 201);
                return;
            }
        }
        if (segs.length == 5 && segs[3] == "workflows") {
            auto wfId = UUID(segs[4]);
            if (req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.getWorkflow(tenantId, wfId), 200);
                return;
            }
        }

        // ── /workflows/:id/start|complete ─────────────────────────────────
        if (segs.length == 6 && segs[3] == "workflows" && segs[5] == "start"
                && req.method == HTTPMethod.POST) {
            auto wfId = UUID(segs[4]);
            res.writeJsonBody(_service.startWorkflow(tenantId, wfId), 200);
            return;
        }
        if (segs.length == 6 && segs[3] == "workflows" && segs[5] == "complete"
                && req.method == HTTPMethod.POST) {
            auto wfId = UUID(segs[4]);
            res.writeJsonBody(_service.completeWorkflow(tenantId, wfId), 200);
            return;
        }

        // ── /workflows/:wfId/tasks ────────────────────────────────────────
        if (segs.length == 6 && segs[3] == "workflows" && segs[5] == "tasks") {
            auto wfId = UUID(segs[4]);
            if (req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.listTasks(tenantId, wfId), 200);
                return;
            }
        }

        // ── /workflows/:wfId/tasks/:taskId ────────────────────────────────
        if (segs.length == 7 && segs[3] == "workflows" && segs[5] == "tasks") {
            auto wfId   = UUID(segs[4]);
            auto taskId = UUID(segs[6]);
            if (req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.getTask(tenantId, wfId, taskId), 200);
                return;
            }
        }

        // ── /workflows/:wfId/tasks/:taskId/assign|progress|automate ───────
        if (segs.length == 8 && segs[3] == "workflows" && segs[5] == "tasks"
                && req.method == HTTPMethod.POST) {
            auto wfId   = UUID(segs[4]);
            auto taskId = UUID(segs[6]);
            auto action = segs[7];
            if (action == "assign") {
                res.writeJsonBody(_service.assignTask(tenantId, wfId, taskId, req.json), 200);
                return;
            }
            if (action == "progress") {
                res.writeJsonBody(_service.progressTask(tenantId, wfId, taskId, req.json), 200);
                return;
            }
            if (action == "automate") {
                res.writeJsonBody(_service.automateTask(tenantId, wfId, taskId), 200);
                return;
            }
        }

        // ── /workflows/:wfId/parameters ───────────────────────────────────
        if (segs.length == 6 && segs[3] == "workflows" && segs[5] == "parameters") {
            auto wfId = UUID(segs[4]);
            if (req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.listParameters(tenantId, wfId), 200);
                return;
            }
            if (req.method == HTTPMethod.POST) {
                res.writeJsonBody(_service.setParameter(tenantId, wfId, req.json), 200);
                return;
            }
        }

        // ── /workflows/:wfId/logs (monitoring) ────────────────────────────
        if (segs.length == 6 && segs[3] == "workflows" && segs[5] == "logs") {
            auto wfId = UUID(segs[4]);
            if (req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.listLogs(tenantId, wfId), 200);
                return;
            }
        }

        respondError(res, "Not found", 404);
    }

    // -----------------------------------------------------------------------
    // Auth helper
    // -----------------------------------------------------------------------
    private void validateAuth(HTTPServerRequest req) {
        if (!_service.config.requireAuthToken)
            return;
        auto authHeader = req.headers.get("Authorization", "");
        if (authHeader.length == 0)
            throw new CIAAuthorizationException("Missing Authorization header");
        if (authHeader.length < 8 || authHeader[0 .. 7] != "Bearer ")
            throw new CIAAuthorizationException("Authorization header must use Bearer scheme");
        auto token = authHeader[7 .. $];
        if (token != _service.config.authToken)
            throw new CIAAuthorizationException("Invalid auth token");
    }

    // -----------------------------------------------------------------------
    // Helpers
    // -----------------------------------------------------------------------
    private static string[] normalizedSegments(string path) {
        auto parts = path.split("/");
        string[] segs;
        foreach (p; parts)
            if (p.length > 0)
                segs ~= p;
        return segs;
    }

    private static void respondError(HTTPServerResponse res, string message, int status) {
        Json err = Json.emptyObject;
        err["error"]   = message;
        err["status"]  = status;
        res.writeJsonBody(err, status);
    }
}
