module uim.sap.kst.server;

import std.array : split;
import std.string : startsWith;

import vibe.data.json : Json;
import vibe.http.common : HTTPMethod;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse, HTTPServerSettings, listenHTTP;

import uim.sap.kst.exceptions;
import uim.sap.kst.service;

/**
 * HTTP server for the Keystore Service.
 *
 * Routes:
 *   GET  /health
 *   GET  /ready
 *
 *   GET    /v1/keystores
 *   POST   /v1/keystores/{name}
 *   PUT    /v1/keystores/{name}
 *   GET    /v1/keystores/{name}
 *   DELETE /v1/keystores/{name}
 *
 *   PUT    /v1/keystores/{name}/keys/{alias}
 *   GET    /v1/keystores/{name}/keys/{alias}
 *   GET    /v1/keystores/{name}/keys
 *   DELETE /v1/keystores/{name}/keys/{alias}
 *
 *   PUT    /v1/keystores/{name}/certificates/{alias}
 *   GET    /v1/keystores/{name}/certificates/{alias}
 *   GET    /v1/keystores/{name}/certificates
 *   DELETE /v1/keystores/{name}/certificates/{alias}
 *
 *   POST   /v1/keystores/{name}/keys/{alias}/sign
 *   POST   /v1/keystores/{name}/keys/{alias}/verify
 *   POST   /v1/keystores/{name}/keys/{alias}/encrypt
 *   POST   /v1/keystores/{name}/keys/{alias}/decrypt
 *
 *   POST   /v1/auth/client-cert
 */
class KSTServer {
    private KSTService _service;

    this(KSTService service) {
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

        auto requestKey = req.headers.get("X-KST-Encryption-Key", "");

        try {
            validateAuth(req);
            auto segments = normalizedSegments(subPath);

            // POST /v1/auth/client-cert
            if (segments.length == 3 && segments[0] == "v1" && segments[1] == "auth" && segments[2] == "client-cert" && req.method == HTTPMethod.POST) {
                res.writeJsonBody(_service.validateClientCert(req.json), 200);
                return;
            }

            // /v1/keystores...
            if (segments.length >= 2 && segments[0] == "v1" && segments[1] == "keystores") {
                routeKeystores(req, res, segments[2 .. $], requestKey);
                return;
            }

            respondError(res, "Not found", 404);
        } catch (KSTAuthorizationException e) {
            respondError(res, e.msg, 401);
        } catch (KSTNotFoundException e) {
            respondError(res, e.msg, 404);
        } catch (KSTValidationException e) {
            respondError(res, e.msg, 422);
        } catch (KSTCryptoException e) {
            respondError(res, e.msg, 400);
        } catch (KSTException e) {
            respondError(res, e.msg, 500);
        } catch (Exception e) {
            respondError(res, e.msg, 500);
        }
    }

    private void routeKeystores(HTTPServerRequest req, HTTPServerResponse res, string[] segments, string requestKey) {
        // GET /v1/keystores
        if (segments.length == 0 && req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listKeystores(), 200);
            return;
        }

        if (segments.length == 0) {
            respondError(res, "Not found", 404);
            return;
        }

        auto ksName = segments[0];

        // POST /v1/keystores/{name}  (create)
        if (segments.length == 1 && req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createKeystore(ksName, req.json), 201);
            return;
        }
        // PUT /v1/keystores/{name}  (update)
        if (segments.length == 1 && req.method == HTTPMethod.PUT) {
            res.writeJsonBody(_service.updateKeystore(ksName, req.json), 200);
            return;
        }
        // GET /v1/keystores/{name}
        if (segments.length == 1 && req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getKeystore(ksName), 200);
            return;
        }
        // DELETE /v1/keystores/{name}
        if (segments.length == 1 && req.method == HTTPMethod.DELETE) {
            res.writeJsonBody(_service.deleteKeystore(ksName), 200);
            return;
        }

        if (segments.length >= 2) {
            auto resource = segments[1];

            // ── Keys ──
            if (resource == "keys") {
                // GET /v1/keystores/{name}/keys
                if (segments.length == 2 && req.method == HTTPMethod.GET) {
                    res.writeJsonBody(_service.listKeyEntries(ksName), 200);
                    return;
                }
                if (segments.length >= 3) {
                    auto alias_ = segments[2];

                    // Crypto operations: /v1/keystores/{name}/keys/{alias}/{op}
                    if (segments.length == 4 && req.method == HTTPMethod.POST) {
                        auto op = segments[3];
                        if (op == "sign") {
                            res.writeJsonBody(_service.sign(ksName, alias_, req.json, requestKey), 200);
                            return;
                        }
                        if (op == "verify") {
                            res.writeJsonBody(_service.verify(ksName, alias_, req.json, requestKey), 200);
                            return;
                        }
                        if (op == "encrypt") {
                            res.writeJsonBody(_service.encrypt(ksName, alias_, req.json, requestKey), 200);
                            return;
                        }
                        if (op == "decrypt") {
                            res.writeJsonBody(_service.decrypt(ksName, alias_, req.json, requestKey), 200);
                            return;
                        }
                    }

                    // PUT /v1/keystores/{name}/keys/{alias}
                    if (segments.length == 3 && req.method == HTTPMethod.PUT) {
                        res.writeJsonBody(_service.upsertKeyEntry(ksName, alias_, req.json, requestKey), 200);
                        return;
                    }
                    // GET /v1/keystores/{name}/keys/{alias}
                    if (segments.length == 3 && req.method == HTTPMethod.GET) {
                        res.writeJsonBody(_service.getKeyEntry(ksName, alias_, requestKey), 200);
                        return;
                    }
                    // DELETE /v1/keystores/{name}/keys/{alias}
                    if (segments.length == 3 && req.method == HTTPMethod.DELETE) {
                        res.writeJsonBody(_service.deleteKeyEntry(ksName, alias_), 200);
                        return;
                    }
                }
            }

            // ── Certificates ──
            if (resource == "certificates") {
                // GET /v1/keystores/{name}/certificates
                if (segments.length == 2 && req.method == HTTPMethod.GET) {
                    res.writeJsonBody(_service.listCertificates(ksName), 200);
                    return;
                }
                if (segments.length >= 3) {
                    auto alias_ = segments[2];
                    auto includeContent = req.params.get("include_content", "false") == "true";

                    // PUT /v1/keystores/{name}/certificates/{alias}
                    if (segments.length == 3 && req.method == HTTPMethod.PUT) {
                        res.writeJsonBody(_service.upsertCertificate(ksName, alias_, req.json), 200);
                        return;
                    }
                    // GET /v1/keystores/{name}/certificates/{alias}
                    if (segments.length == 3 && req.method == HTTPMethod.GET) {
                        res.writeJsonBody(_service.getCertificate(ksName, alias_, includeContent), 200);
                        return;
                    }
                    // DELETE /v1/keystores/{name}/certificates/{alias}
                    if (segments.length == 3 && req.method == HTTPMethod.DELETE) {
                        res.writeJsonBody(_service.deleteCertificate(ksName, alias_), 200);
                        return;
                    }
                }
            }
        }

        respondError(res, "Not found", 404);
    }

    private void validateAuth(HTTPServerRequest req) {
        if (!_service.config.requireAuthToken)
            return;

        if (!("Authorization" in req.headers))
            throw new KSTAuthorizationException("Missing Authorization header");

        auto expected = "Bearer " ~ _service.config.authToken;
        if (req.headers["Authorization"] != expected)
            throw new KSTAuthorizationException("Invalid token");
    }

    private string[] normalizedSegments(string subPath) {
        auto clean = subPath;
        if (clean.length > 0 && clean[0] == '/')
            clean = clean[1 .. $];
        if (clean.length > 0 && clean[$ - 1] == '/')
            clean = clean[0 .. $ - 1];
        if (clean.length == 0)
            return null;
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

///
unittest {
    mixin(ShowTest!("Testing KSTServer"));
}
