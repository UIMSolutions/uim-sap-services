module uim.sap.slm.server;

import std.array  : split;
import std.string : startsWith;

import vibe.data.json   : Json;
import vibe.http.common : HTTPMethod;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse,
                          HTTPServerSettings, listenHTTP;

import uim.sap.slm.exceptions;
import uim.sap.slm.service;

// ---------------------------------------------------------------------------
// SLMServer – Vibe.D HTTP server for Solution Lifecycle Management
// ---------------------------------------------------------------------------
class SLMServer {
    private SLMService _service;

    this(SLMService service) {
        _service = service;
    }

    void run() {
        auto settings = new HTTPServerSettings;
        settings.port          = _service.config.port;
        settings.bindAddresses = [_service.config.host];
        listenHTTP(settings, &handleRequest);
        runApplication();
    }

    // -----------------------------------------------------------------------
    // Root dispatcher
    // -----------------------------------------------------------------------
    private void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
        foreach (key, value; _service.config.customHeaders)
            res.headers[key] = value;

        auto basePath = _service.config.basePath;
        auto path     = req.path;

        if (!path.startsWith(basePath)) {
            respondError(res, "Not found", 404);
            return;
        }

        auto subPath = path[basePath.length .. $];
        if (subPath.length == 0) subPath = "/";

        // ── Dashboard ─────────────────────────────────────────────────────
        if (subPath == "/" && req.method == HTTPMethod.GET) {
            res.contentType = "text/html; charset=utf-8";
            res.writeBody(_service.dashboardHtml());
            return;
        }

        // ── Health / readiness ────────────────────────────────────────────
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
            routeRequest(req, res, subPath);
        }
        catch (SLMNotFoundException e)        { respondError(res, e.msg, 404); }
        catch (SLMValidationException e)      { respondError(res, e.msg, 400); }
        catch (SLMAuthorizationException e)   { respondError(res, e.msg, 403); }
        catch (SLMSolutionStateException e)   { respondError(res, e.msg, 409); }
        catch (SLMException e)                { respondError(res, e.msg, 500); }
    }

    // -----------------------------------------------------------------------
    // Route matching – /v1/tenants/:tenantId/...
    // -----------------------------------------------------------------------
    private void routeRequest(HTTPServerRequest req, HTTPServerResponse res, string subPath) {
        auto segs = segments(subPath);

        if (segs.length < 3 || segs[0] != "v1" || segs[1] != "tenants") {
            respondError(res, "Not found", 404);
            return;
        }
        auto tenantId = segs[2];

        // ── /solutions ────────────────────────────────────────────────────
        if (segs.length == 4 && segs[3] == "solutions") {
            if (req.method == HTTPMethod.GET)  { res.writeJsonBody(_service.listSolutions(tenantId), 200); return; }
            if (req.method == HTTPMethod.POST) { res.writeJsonBody(_service.deploySolution(tenantId, req.json), 201); return; }
        }

        // ── /solutions/:id ────────────────────────────────────────────────
        if (segs.length == 5 && segs[3] == "solutions") {
            auto solId = segs[4];
            if (req.method == HTTPMethod.GET)    { res.writeJsonBody(_service.getSolution(tenantId, solId), 200); return; }
            if (req.method == HTTPMethod.PUT)    { res.writeJsonBody(_service.updateSolution(tenantId, solId, req.json), 200); return; }
            if (req.method == HTTPMethod.DELETE) { res.writeJsonBody(_service.deleteSolution(tenantId, solId), 200); return; }
        }

        // ── /solutions/:id/components ─────────────────────────────────────
        if (segs.length == 6 && segs[3] == "solutions" && segs[5] == "components") {
            if (req.method == HTTPMethod.GET) { res.writeJsonBody(_service.listComponents(tenantId, segs[4]), 200); return; }
        }
        // ── /solutions/:id/components/:cid ────────────────────────────────
        if (segs.length == 7 && segs[3] == "solutions" && segs[5] == "components") {
            if (req.method == HTTPMethod.GET) { res.writeJsonBody(_service.getComponent(tenantId, segs[4], segs[6]), 200); return; }
        }

        // ── /solutions/:id/deployments ────────────────────────────────────
        if (segs.length == 6 && segs[3] == "solutions" && segs[5] == "deployments") {
            if (req.method == HTTPMethod.GET) { res.writeJsonBody(_service.listDeploymentsForSolution(tenantId, segs[4]), 200); return; }
        }

        // ── /solutions/:id/subscriptions ──────────────────────────────────
        if (segs.length == 6 && segs[3] == "solutions" && segs[5] == "subscriptions") {
            auto solId = segs[4];
            if (req.method == HTTPMethod.GET)  { res.writeJsonBody(_service.listSubscriptionsForSolution(tenantId, solId), 200); return; }
            if (req.method == HTTPMethod.POST) { res.writeJsonBody(_service.subscribe(tenantId, solId, req.json), 201); return; }
        }
        // ── /solutions/:id/subscriptions/:subId/unsubscribe ───────────────
        if (segs.length == 8 && segs[3] == "solutions" && segs[5] == "subscriptions"
                && segs[7] == "unsubscribe" && req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.unsubscribe(tenantId, segs[4], segs[6]), 200);
            return;
        }

        // ── /solutions/:id/licenses ───────────────────────────────────────
        if (segs.length == 6 && segs[3] == "solutions" && segs[5] == "licenses") {
            if (req.method == HTTPMethod.GET) { res.writeJsonBody(_service.listLicensesForSolution(tenantId, segs[4]), 200); return; }
        }

        // ── /solutions/:id/logs ───────────────────────────────────────────
        if (segs.length == 6 && segs[3] == "solutions" && segs[5] == "logs") {
            if (req.method == HTTPMethod.GET) { res.writeJsonBody(_service.listLogs(tenantId, segs[4]), 200); return; }
        }

        // ── /deployments (all tenant deployments) ─────────────────────────
        if (segs.length == 4 && segs[3] == "deployments") {
            if (req.method == HTTPMethod.GET) { res.writeJsonBody(_service.listDeployments(tenantId), 200); return; }
        }

        // ── /subscriptions (all tenant subscriptions) ─────────────────────
        if (segs.length == 4 && segs[3] == "subscriptions") {
            if (req.method == HTTPMethod.GET) { res.writeJsonBody(_service.listSubscriptions(tenantId), 200); return; }
        }

        respondError(res, "Not found", 404);
    }

    // -----------------------------------------------------------------------
    // Auth
    // -----------------------------------------------------------------------
    private void validateAuth(HTTPServerRequest req) {
        if (!_service.config.requireAuthToken) return;
        auto authHeader = req.headers.get("Authorization", "");
        if (authHeader.length == 0)
            throw new SLMAuthorizationException("Missing Authorization header");
        if (authHeader.length < 8 || authHeader[0 .. 7] != "Bearer ")
            throw new SLMAuthorizationException("Authorization must use Bearer scheme");
        if (authHeader[7 .. $] != _service.config.authToken)
            throw new SLMAuthorizationException("Invalid auth token");
    }

    // -----------------------------------------------------------------------
    // Helpers
    // -----------------------------------------------------------------------
    private static string[] segments(string path) {
        auto parts = path.split("/");
        string[] segs;
        foreach (p; parts) if (p.length > 0) segs ~= p;
        return segs;
    }

    private static void respondError(HTTPServerResponse res, string message, int status) {
        Json err = Json.emptyObject;
        err["error"]  = message;
        err["status"] = status;
        res.writeJsonBody(err, status);
    }
}
