module uim.sap.cps.server;

import std.array : split;
import std.string : startsWith;

import vibe.data.json : Json;
import vibe.http.common : HTTPMethod;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse, HTTPServerSettings, listenHTTP;

import uim.sap.cps.exceptions;
import uim.sap.cps.service;

class CPSServer {
    private CPSService _service;

    this(CPSService service) { _service = service; }

    void run() {
        HTTPServerSettings settings;
        settings.port = _service.config.port;
        settings.bindAddresses = [_service.config.host];
        listenHTTP(settings, &handleRequest);
    }

    private void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
        foreach (key, value; _service.config.customHeaders) res.headers[key] = value;

        auto basePath = _service.config.basePath;
        auto path = req.path;
        if (!path.startsWith(basePath)) {
            respondError(res, "Not found", 404);
            return;
        }

        auto subPath = path[basePath.length .. $];
        if (subPath.length == 0) subPath = "/";

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

                if (segments.length == 4 && segments[3] == "sites") {
                    if (req.method == HTTPMethod.GET) {
                        res.writeJsonBody(_service.listSites(tenantId), 200);
                        return;
                    }
                    if (req.method == HTTPMethod.POST) {
                        res.writeJsonBody(_service.upsertSite(tenantId, req.json), 200);
                        return;
                    }
                }

                if (segments.length == 5 && segments[3] == "sites") {
                    auto siteId = segments[4];
                    if (req.method == HTTPMethod.GET) {
                        res.writeJsonBody(_service.getSite(tenantId, siteId), 200);
                        return;
                    }
                    if (req.method == HTTPMethod.PUT) {
                        Json payload = req.json;
                        payload["site_id"] = siteId;
                        res.writeJsonBody(_service.upsertSite(tenantId, payload), 200);
                        return;
                    }
                    if (req.method == HTTPMethod.DELETE) {
                        res.writeJsonBody(_service.deleteSite(tenantId, siteId), 200);
                        return;
                    }
                }

                if (segments.length == 5 && segments[3] == "navigation" && segments[4] == "resolve" && req.method == HTTPMethod.POST) {
                    res.writeJsonBody(_service.resolveNavigation(tenantId, req.json), 200);
                    return;
                }

                if (segments.length == 4 && segments[3] == "entrypoints" && req.method == HTTPMethod.GET) {
                    res.writeJsonBody(_service.listEntryPoints(tenantId), 200);
                    return;
                }

                if (segments.length == 5 && segments[3] == "admin" && segments[4] == "site-tools") {
                    if (req.method == HTTPMethod.GET) {
                        res.writeJsonBody(_service.getSiteAdministration(tenantId), 200);
                        return;
                    }
                    if (req.method == HTTPMethod.PUT) {
                        res.writeJsonBody(_service.upsertSiteAdministration(tenantId, req.json), 200);
                        return;
                    }
                }

                if (segments.length == 5 && segments[3] == "content") {
                    auto contentType = segments[4];
                    if (req.method == HTTPMethod.GET) {
                        res.writeJsonBody(_service.listContent(tenantId, contentType), 200);
                        return;
                    }
                    if (req.method == HTTPMethod.POST) {
                        res.writeJsonBody(_service.upsertContent(tenantId, contentType, req.json), 200);
                        return;
                    }
                }

                if (segments.length == 5 && segments[3] == "launchpad" && segments[4] == "modules") {
                    if (req.method == HTTPMethod.GET) {
                        res.writeJsonBody(_service.listLaunchpadModules(tenantId), 200);
                        return;
                    }
                    if (req.method == HTTPMethod.POST) {
                        res.writeJsonBody(_service.upsertLaunchpadModule(tenantId, req.json), 200);
                        return;
                    }
                }

                if (segments.length == 5 && segments[3] == "providers") {
                    if (req.method == HTTPMethod.GET) {
                        res.writeJsonBody(_service.listProviders(tenantId), 200);
                        return;
                    }
                    if (req.method == HTTPMethod.POST) {
                        res.writeJsonBody(_service.upsertProvider(tenantId, req.json), 200);
                        return;
                    }
                }

                if (segments.length == 6 && segments[3] == "providers" && segments[5] == "consume" && req.method == HTTPMethod.POST) {
                    auto providerId = segments[4];
                    res.writeJsonBody(_service.consumeProvider(tenantId, providerId), 200);
                    return;
                }
            }

            respondError(res, "Not found", 404);
        } catch (CPSAuthorizationException e) {
            respondError(res, e.msg, 401);
        } catch (CPSNotFoundException e) {
            respondError(res, e.msg, 404);
        } catch (CPSValidationException e) {
            respondError(res, e.msg, 422);
        } catch (CPSException e) {
            respondError(res, e.msg, 500);
        } catch (Exception e) {
            respondError(res, e.msg, 500);
        }
    }

    private void validateAuth(HTTPServerRequest req) {
        if (!_service.config.requireAuthToken) return;
        if (!("Authorization" in req.headers)) throw new CPSAuthorizationException("Missing Authorization header");
        auto expected = "Bearer " ~ _service.config.authToken;
        if (req.headers["Authorization"] != expected) throw new CPSAuthorizationException("Invalid token");
    }

    private string[] normalizedSegments(string subPath) {
        auto clean = subPath;
        if (clean.length > 0 && clean[0] == '/') clean = clean[1 .. $];
        if (clean.length > 0 && clean[$ - 1] == '/') clean = clean[0 .. $ - 1];
        if (clean.length == 0) return [];
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
