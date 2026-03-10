module uim.sap.obs.server;

import std.array : split;
import std.string : startsWith;

import vibe.data.json : Json;
import vibe.http.common : HTTPMethod;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse, HTTPServerSettings, listenHTTP;

import uim.sap.obs.exceptions;
import uim.sap.obs.service;

/**
 * HTTP server for Object Store on SAP BTP.
 *
 * Routes:
 *   GET  /health
 *   GET  /ready
 *   GET  /v1/metrics
 *
 *   Buckets:
 *     GET    /v1/buckets              — List buckets
 *     POST   /v1/buckets              — Create bucket
 *     GET    /v1/buckets/{id}         — Get bucket
 *     PUT    /v1/buckets/{id}         — Update bucket
 *     DELETE /v1/buckets/{id}         — Delete bucket
 *     POST   /v1/buckets/{id}/suspend — Suspend bucket
 *
 *   Objects:
 *     GET    /v1/buckets/{id}/objects              — List objects (?prefix=...)
 *     POST   /v1/buckets/{id}/objects              — Upload object
 *     GET    /v1/buckets/{id}/objects/{key}         — Download object
 *     HEAD   /v1/buckets/{id}/objects/{key}         — Head object
 *     DELETE /v1/buckets/{id}/objects/{key}         — Delete object
 *     GET    /v1/buckets/{id}/objects/{key}/versions — List versions
 *
 *   Credentials:
 *     GET    /v1/buckets/{id}/credentials           — List credentials
 *     POST   /v1/buckets/{id}/credentials           — Create credentials
 *     DELETE /v1/credentials/{id}                   — Revoke credential
 *
 *   Policies:
 *     GET    /v1/buckets/{id}/policies              — List policies
 *     POST   /v1/buckets/{id}/policies              — Create policy
 *     GET    /v1/policies/{id}                      — Get policy
 *     DELETE /v1/policies/{id}                      — Delete policy
 */
class OBSServer {
    private OBSService _service;

    this(OBSService service) {
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

        // Health / ready (no auth)
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

            // GET /v1/metrics
            if (segments.length == 2 && segments[0] == "v1" && segments[1] == "metrics"
                    && req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.getMetrics(), 200);
                return;
            }

            // /v1/buckets...
            if (segments.length >= 2 && segments[0] == "v1" && segments[1] == "buckets") {
                routeBuckets(req, res, segments[2 .. $]);
                return;
            }

            // /v1/credentials/{id} — revoke
            if (segments.length == 3 && segments[0] == "v1" && segments[1] == "credentials"
                    && req.method == HTTPMethod.DELETE) {
                res.writeJsonBody(_service.revokeCredentials(segments[2]), 200);
                return;
            }

            // /v1/policies/{id}
            if (segments.length == 3 && segments[0] == "v1" && segments[1] == "policies") {
                if (req.method == HTTPMethod.GET) {
                    res.writeJsonBody(_service.getPolicy(segments[2]), 200);
                    return;
                }
                if (req.method == HTTPMethod.DELETE) {
                    res.writeJsonBody(_service.deletePolicy(segments[2]), 200);
                    return;
                }
                respondError(res, "Method not allowed", 405);
                return;
            }

            respondError(res, "Not found", 404);
        } catch (OBSAuthorizationException e) {
            respondError(res, e.msg, 401);
        } catch (OBSConflictException e) {
            respondError(res, e.msg, 409);
        } catch (OBSNotFoundException e) {
            respondError(res, e.msg, 404);
        } catch (OBSValidationException e) {
            respondError(res, e.msg, 400);
        } catch (OBSQuotaExceededException e) {
            respondError(res, e.msg, 429);
        } catch (OBSConfigurationException e) {
            respondError(res, e.msg, 500);
        } catch (OBSException e) {
            respondError(res, e.msg, 500);
        } catch (Exception e) {
            respondError(res, "Internal server error", 500);
        }
    }

    // ──────────────────────────────────────
    //  Bucket Routes
    // ──────────────────────────────────────

    private void routeBuckets(HTTPServerRequest req, HTTPServerResponse res, string[] rest) {
        // GET|POST /v1/buckets
        if (rest.length == 0) {
            if (req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.listBuckets(), 200);
                return;
            }
            if (req.method == HTTPMethod.POST) {
                Json body_ = parseBody(req);
                res.writeJsonBody(_service.createBucket(body_), 201);
                return;
            }
            respondError(res, "Method not allowed", 405);
            return;
        }

        string bucketId = rest[0];

        // POST /v1/buckets/{id}/suspend
        if (rest.length == 2 && rest[1] == "suspend" && req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.suspendBucket(bucketId), 200);
            return;
        }

        // /v1/buckets/{id}/objects...
        if (rest.length >= 2 && rest[1] == "objects") {
            routeObjects(req, res, bucketId, rest[2 .. $]);
            return;
        }

        // /v1/buckets/{id}/credentials
        if (rest.length == 2 && rest[1] == "credentials") {
            if (req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.listCredentials(bucketId), 200);
                return;
            }
            if (req.method == HTTPMethod.POST) {
                Json body_ = parseBody(req);
                res.writeJsonBody(_service.createCredentials(bucketId, body_), 201);
                return;
            }
            respondError(res, "Method not allowed", 405);
            return;
        }

        // /v1/buckets/{id}/policies
        if (rest.length == 2 && rest[1] == "policies") {
            if (req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.listPolicies(bucketId), 200);
                return;
            }
            if (req.method == HTTPMethod.POST) {
                Json body_ = parseBody(req);
                res.writeJsonBody(_service.createPolicy(bucketId, body_), 201);
                return;
            }
            respondError(res, "Method not allowed", 405);
            return;
        }

        // GET|PUT|DELETE /v1/buckets/{id}
        if (rest.length == 1) {
            if (req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.getBucket(bucketId), 200);
                return;
            }
            if (req.method == HTTPMethod.PUT) {
                Json body_ = parseBody(req);
                res.writeJsonBody(_service.updateBucket(bucketId, body_), 200);
                return;
            }
            if (req.method == HTTPMethod.DELETE) {
                res.writeJsonBody(_service.deleteBucket(bucketId), 200);
                return;
            }
            respondError(res, "Method not allowed", 405);
            return;
        }

        respondError(res, "Not found", 404);
    }

    // ──────────────────────────────────────
    //  Object Routes
    // ──────────────────────────────────────

    private void routeObjects(HTTPServerRequest req, HTTPServerResponse res,
            string bucketId, string[] rest) {
        // GET|POST /v1/buckets/{id}/objects
        if (rest.length == 0) {
            if (req.method == HTTPMethod.GET) {
                string prefix = req.params.get("prefix", "");
                res.writeJsonBody(_service.listObjects(bucketId, prefix), 200);
                return;
            }
            if (req.method == HTTPMethod.POST) {
                Json body_ = parseBody(req);
                res.writeJsonBody(_service.uploadObject(bucketId, body_), 201);
                return;
            }
            respondError(res, "Method not allowed", 405);
            return;
        }

        // Object key is the remaining path segments joined by /
        // Check for /versions suffix first
        if (rest.length >= 2 && rest[$ - 1] == "versions") {
            string key = joinSegments(rest[0 .. $ - 1]);
            if (req.method == HTTPMethod.GET) {
                res.writeJsonBody(_service.listObjectVersions(bucketId, key), 200);
                return;
            }
            respondError(res, "Method not allowed", 405);
            return;
        }

        string key = joinSegments(rest);

        // GET /v1/buckets/{id}/objects/{key...} — download
        if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.downloadObject(bucketId, key), 200);
            return;
        }
        // HEAD /v1/buckets/{id}/objects/{key...} — head
        if (req.method == HTTPMethod.HEAD) {
            res.writeJsonBody(_service.headObject(bucketId, key), 200);
            return;
        }
        // DELETE /v1/buckets/{id}/objects/{key...} — delete
        if (req.method == HTTPMethod.DELETE) {
            res.writeJsonBody(_service.deleteObject(bucketId, key), 200);
            return;
        }

        respondError(res, "Method not allowed", 405);
    }

    // ──────────────────────────────────────
    //  Helpers
    // ──────────────────────────────────────

    private void validateAuth(HTTPServerRequest req) {
        if (!_service.config.requireAuthToken)
            return;
        auto authHeader = req.headers.get("Authorization", "");
        if (!authHeader.startsWith("Bearer "))
            throw new OBSAuthorizationException("Missing bearer token");
        auto token = authHeader[7 .. $];
        if (token != _service.config.authToken)
            throw new OBSAuthorizationException("Invalid bearer token");
    }

    private static string[] normalizedSegments(string path) {
        import std.algorithm : filter;
        import std.array : array;
        return path.split("/").filter!(s => s.length > 0).array;
    }

    private static string joinSegments(string[] segs) {
        import std.array : join;
        return segs.join("/");
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
