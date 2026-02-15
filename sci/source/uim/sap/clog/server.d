/**
 * HTTP server for SCI cloud logging service
 */
module uim.sap.sci.server;

import std.string : startsWith, endsWith;

import vibe.data.json : Json;
import vibe.http.common : HTTPMethod;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse, HTTPServerSettings, listenHTTP;

import uim.sap.sci.exceptions;
import uim.sap.sci.service;

class SCIServer {
    private SCIService _service;

    this(SCIService service) {
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

        if (path.endsWith("/health") && req.method == HTTPMethod.GET) {
            res.statusCode = 200;
            res.writeJsonBody(_service.health());
            return;
        }

        if (path.endsWith("/ready") && req.method == HTTPMethod.GET) {
            res.statusCode = 200;
            res.writeJsonBody(_service.ready());
            return;
        }

        if (path.endsWith("/metrics") && req.method == HTTPMethod.GET) {
            res.statusCode = 200;
            res.writeJsonBody(_service.metrics());
            return;
        }

        if (path.endsWith("/logs") && req.method == HTTPMethod.POST) {
            handleAuthorizedRequest(req, res, (body) => _service.ingest(body));
            return;
        }

        if (path.endsWith("/logs/batch") && req.method == HTTPMethod.POST) {
            handleAuthorizedRequest(req, res, (body) => _service.ingestBatch(body));
            return;
        }

        if (path.endsWith("/logs/query") && req.method == HTTPMethod.POST) {
            handleAuthorizedRequest(req, res, (body) => _service.query(body));
            return;
        }

        respondError(res, "Not found", 404);
    }

    private void handleAuthorizedRequest(
        HTTPServerRequest req,
        HTTPServerResponse res,
        Json delegate(Json) action
    ) {
        try {
            validateAuth(req);
            auto input = req.json;
            auto output = action(input);
            res.statusCode = 200;
            res.writeJsonBody(output);
        } catch (SCIAuthorizationException e) {
            respondError(res, e.msg, 401);
        } catch (SCILogValidationException e) {
            respondError(res, e.msg, 422);
        } catch (SCIException e) {
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
            throw new SCIAuthorizationException("Missing Authorization header");
        }

        auto expected = "Bearer " ~ _service.config.authToken;
        if (req.headers["Authorization"] != expected) {
            throw new SCIAuthorizationException("Invalid token");
        }
    }

    private void respondError(HTTPServerResponse res, string message, int statusCode) {
        Json payload = Json.emptyObject;
        payload["success"] = false;
        payload["message"] = message;
        payload["statusCode"] = statusCode;
        res.statusCode = statusCode;
        res.writeJsonBody(payload);
    }
}
