/**
 * HTTP server adapter for SAP ABAP Runtime (ART)
 */
module uim.sap.art.server;

import std.string : endsWith, startsWith;

import vibe.data.json : Json;
import vibe.http.common : HTTPMethod;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse, HTTPServerSettings, listenHTTP;

import uim.sap.art.exceptions;
import uim.sap.art.models;
import uim.sap.art.runtime;

class ARTRuntimeServer {
    private ARTRuntime _runtime;

    this(ARTRuntime runtime) {
        _runtime = runtime;
    }

    ARTRuntime runtime() {
        return _runtime;
    }

    void run() {
        HTTPServerSettings settings;
        settings.port = _runtime.config.port;
        settings.bindAddresses = [_runtime.config.host];
        listenHTTP(settings, &handleRequest);
    }

    private void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
        foreach (key, value; _runtime.config.customHeaders) {
            res.headers[key] = value;
        }

        auto basePath = _runtime.config.basePath;
        auto path = req.path;

        if (!path.startsWith(basePath)) {
            respondError(res, "Not found", 404);
            return;
        }

        if (path.endsWith("/health") && req.method == HTTPMethod.GET) {
            res.statusCode = 200;
            res.writeJsonBody(_runtime.health().toJson());
            return;
        }

        if (path.endsWith("/programs") && req.method == HTTPMethod.GET) {
            Json payload = Json.emptyObject;
            Json programs = Json.emptyArray;
            foreach (name; _runtime.listPrograms()) {
                programs ~= Json(name);
            }
            payload["programs"] = programs;
            payload["count"] = cast(long)_runtime.registeredProgramCount;
            res.statusCode = 200;
            res.writeJsonBody(payload);
            return;
        }

        if (path.endsWith("/run") && req.method == HTTPMethod.POST) {
            try {
                validateAuth(req);
                auto input = req.json;
                auto programRequest = ARTProgramRequest.fromJson(input);
                auto output = _runtime.execute(programRequest);
                res.statusCode = output.statusCode;
                res.writeJsonBody(output.toJson());
            } catch (ARTRuntimeAuthenticationException e) {
                respondError(res, e.msg, 401);
            } catch (ARTRuntimeProgramNotFoundException e) {
                respondError(res, e.msg, 404);
            } catch (ARTRuntimeExecutionException e) {
                respondError(res, e.msg, 422);
            } catch (ARTRuntimeException e) {
                respondError(res, e.msg, 500);
            } catch (Exception e) {
                respondError(res, e.msg, 500);
            }
            return;
        }

        respondError(res, "Not found", 404);
    }

    private void validateAuth(HTTPServerRequest req) {
        if (!_runtime.config.requireAuthToken) {
            return;
        }

        if (!("Authorization" in req.headers)) {
            throw new ARTRuntimeAuthenticationException("Missing Authorization header");
        }

        auto auth = req.headers["Authorization"];
        auto expected = "Bearer " ~ _runtime.config.authToken;
        if (auth != expected) {
            throw new ARTRuntimeAuthenticationException("Invalid token");
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
