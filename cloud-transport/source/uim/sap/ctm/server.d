module uim.sap.ctm.server;

import std.array  : split;
import std.string : startsWith;

import vibe.data.json   : Json;
import vibe.http.common : HTTPMethod;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse,
                          HTTPServerSettings, listenHTTP;

import uim.sap.ctm.exceptions;
import uim.sap.ctm.service;

// ---------------------------------------------------------------------------
// CTMServer – Vibe.D HTTP server for Cloud Transport Management
// ---------------------------------------------------------------------------
class CTMServer {
    private CTMService _service;

    this(CTMService service) {
        _service = service;
    }

    // -----------------------------------------------------------------------
    // Root dispatcher
    // -----------------------------------------------------------------------
    override void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
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
        catch (CTMNotFoundException e)       { respondError(res, e.msg, 404); }
        catch (CTMValidationException e)     { respondError(res, e.msg, 400); }
        catch (CTMAuthorizationException e)  { respondError(res, e.msg, 403); }
        catch (CTMTransportStateException e) { respondError(res, e.msg, 409); }
        catch (CTMException e)               { respondError(res, e.msg, 500); }
    }

    // -----------------------------------------------------------------------
    // Route matching
    // -----------------------------------------------------------------------
    private void routeRequest(HTTPServerRequest req, HTTPServerResponse res, string subPath) {
        auto segs = segments(subPath);

        // All API routes start with v1/tenants/:tenantId
        if (segs.length < 3 || segs[0] != "v1" || segs[1] != "tenants") {
            respondError(res, "Not found", 404);
            return;
        }
        auto tenantId = segs[2];

        // ── /nodes ────────────────────────────────────────────────────────
        if (segs.length == 4 && segs[3] == "nodes") {
            if (req.method == HTTPMethod.GET)  { res.writeJsonBody(_service.listNodes(tenantId), 200); return; }
            if (req.method == HTTPMethod.POST) { res.writeJsonBody(_service.createNode(tenantId, req.json), 201); return; }
        }
        if (segs.length == 5 && segs[3] == "nodes") {
            if (req.method == HTTPMethod.GET) { res.writeJsonBody(_service.getNode(tenantId, segs[4]), 200); return; }
        }

        // ── /nodes/:id/queue ──────────────────────────────────────────────
        if (segs.length == 6 && segs[3] == "nodes" && segs[5] == "queue") {
            if (req.method == HTTPMethod.GET)  { res.writeJsonBody(_service.listQueue(tenantId, segs[4]), 200); return; }
        }
        // ── /nodes/:id/queue/import ───────────────────────────────────────
        if (segs.length == 7 && segs[3] == "nodes" && segs[5] == "queue"
                && segs[6] == "import" && req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.importQueue(tenantId, segs[4], req.json), 200);
            return;
        }
        // ── /nodes/:id/queue/schedule ─────────────────────────────────────
        if (segs.length == 7 && segs[3] == "nodes" && segs[5] == "queue"
                && segs[6] == "schedule" && req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.setImportSchedule(tenantId, segs[4], req.json), 200);
            return;
        }

        // ── /routes ───────────────────────────────────────────────────────
        if (segs.length == 4 && segs[3] == "routes") {
            if (req.method == HTTPMethod.GET)  { res.writeJsonBody(_service.listRoutes(tenantId), 200); return; }
            if (req.method == HTTPMethod.POST) { res.writeJsonBody(_service.createRoute(tenantId, req.json), 201); return; }
        }

        // ── /requests ─────────────────────────────────────────────────────
        if (segs.length == 4 && segs[3] == "requests") {
            if (req.method == HTTPMethod.GET)  { res.writeJsonBody(_service.listRequests(tenantId), 200); return; }
            if (req.method == HTTPMethod.POST) { res.writeJsonBody(_service.createRequest(tenantId, req.json), 201); return; }
        }
        if (segs.length == 5 && segs[3] == "requests") {
            if (req.method == HTTPMethod.GET) { res.writeJsonBody(_service.getRequest(tenantId, segs[4]), 200); return; }
        }

        // ── /requests/:id/forward ─────────────────────────────────────────
        if (segs.length == 6 && segs[3] == "requests" && segs[5] == "forward"
                && req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.forwardRequest(tenantId, segs[4]), 200);
            return;
        }

        // ── /requests/:id/reset ───────────────────────────────────────────
        if (segs.length == 6 && segs[3] == "requests" && segs[5] == "reset"
                && req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.resetRequest(tenantId, segs[4]), 200);
            return;
        }

        // ── /requests/:id/content ─────────────────────────────────────────
        if (segs.length == 6 && segs[3] == "requests" && segs[5] == "content") {
            auto reqId = segs[4];
            if (req.method == HTTPMethod.GET)  { res.writeJsonBody(_service.listContent(tenantId, reqId), 200); return; }
            if (req.method == HTTPMethod.POST) { res.writeJsonBody(_service.attachContent(tenantId, reqId, req.json), 201); return; }
        }

        // ── /requests/:id/logs ────────────────────────────────────────────
        if (segs.length == 6 && segs[3] == "requests" && segs[5] == "logs") {
            if (req.method == HTTPMethod.GET) { res.writeJsonBody(_service.listLogs(tenantId, segs[4]), 200); return; }
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
            throw new CTMAuthorizationException("Missing Authorization header");
        if (authHeader.length < 8 || authHeader[0 .. 7] != "Bearer ")
            throw new CTMAuthorizationException("Authorization must use Bearer scheme");
        if (authHeader[7 .. $] != _service.config.authToken)
            throw new CTMAuthorizationException("Invalid auth token");
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
        Json err = Json.emptyObject
            .set("error", message)
            .set("status", status);
            
        res.writeJsonBody(err, status);
    }
}
