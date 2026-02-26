module uim.sap.cdc.server;

import std.array : split;
import std.conv : to;
import std.string : startsWith;

import vibe.data.json : Json;
import vibe.http.common : HTTPMethod;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse, listenHTTP;

import uim.sap.cdc.exceptions;
import uim.sap.cdc.service;

void runCDCServer(
  CDCService service,
  string host,
  ushort port,
  string basePath,
  bool requireAuthToken,
  string authToken
) {
  auto settings = host ~ ":" ~ to!string(port);

  listenHTTP(settings, (req, res) {
    handleRequest(service, basePath, requireAuthToken, authToken, req, res);
  });
}

private void handleRequest(
  CDCService service,
  string basePath,
  bool requireAuthToken,
  string authToken,
  HTTPServerRequest req,
  HTTPServerResponse res
) {
  auto path = req.path;
  if (!path.startsWith(basePath)) {
    respondError(res, "Not found", 404);
    return;
  }

  auto subPath = path[basePath.length .. $];
  if (subPath.length == 0) subPath = "/";

  if (subPath == "/health" && req.method == HTTPMethod.GET) {
    res.writeJsonBody(service.health(), 200);
    return;
  }

  if (subPath == "/ready" && req.method == HTTPMethod.GET) {
    res.writeJsonBody(service.ready(), 200);
    return;
  }

  try {
    validateAuth(requireAuthToken, authToken, req);

    auto segments = normalizedSegments(subPath);

    if (
      segments.length == 4 && segments[0] == "v1" && segments[1] == "tenants" &&
      segments[3] == "profiles"
    ) {
      auto tenantId = segments[2];

      if (req.method == HTTPMethod.POST) {
        res.writeJsonBody(service.upsertProfile(tenantId, req.json), 200);
        return;
      }

      if (req.method == HTTPMethod.GET) {
        auto region = req.query.get("region", "");
        auto search = req.query.get("search", "");
        auto limit = parseSizeT(req.query.get("limit", "100"), 100);
        auto offset = parseSizeT(req.query.get("offset", "0"), 0);
        res.writeJsonBody(service.listProfiles(tenantId, region, search, limit, offset), 200);
        return;
      }
    }

    if (
      segments.length == 5 && segments[0] == "v1" && segments[1] == "tenants" &&
      segments[3] == "profiles" && req.method == HTTPMethod.GET
    ) {
      auto tenantId = segments[2];
      auto userId = segments[4];
      res.writeJsonBody(service.getProfile(tenantId, userId), 200);
      return;
    }

    if (
      segments.length == 6 && segments[0] == "v1" && segments[1] == "tenants" &&
      segments[3] == "profiles" && segments[5] == "consents"
    ) {
      auto tenantId = segments[2];
      auto userId = segments[4];

      if (req.method == HTTPMethod.POST) {
        res.writeJsonBody(service.upsertConsent(tenantId, userId, req.json), 200);
        return;
      }

      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(service.listConsents(tenantId, userId), 200);
        return;
      }
    }

    if (
      segments.length == 4 && segments[0] == "v1" && segments[1] == "tenants" &&
      segments[3] == "site-groups"
    ) {
      auto tenantId = segments[2];

      if (req.method == HTTPMethod.POST) {
        res.writeJsonBody(service.upsertSiteGroup(tenantId, req.json), 200);
        return;
      }

      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(service.listSiteGroups(tenantId), 200);
        return;
      }
    }

    if (
      segments.length == 6 && segments[0] == "v1" && segments[1] == "tenants" &&
      segments[3] == "global-access" && segments[4] == "resolve" && req.method == HTTPMethod.GET
    ) {
      auto tenantId = segments[2];
      auto userId = segments[5];
      auto site = req.query.get("site", "");
      res.writeJsonBody(service.resolveGlobalAccess(tenantId, userId, site), 200);
      return;
    }

    if (
      segments.length == 4 && segments[0] == "v1" && segments[1] == "tenants" &&
      segments[3] == "risk-providers"
    ) {
      auto tenantId = segments[2];

      if (req.method == HTTPMethod.POST) {
        res.writeJsonBody(service.upsertRiskProvider(tenantId, req.json), 200);
        return;
      }

      if (req.method == HTTPMethod.GET) {
        res.writeJsonBody(service.listRiskProviders(tenantId), 200);
        return;
      }
    }

    if (
      segments.length == 4 && segments[0] == "v1" && segments[1] == "tenants" &&
      segments[3] == "authenticate" && req.method == HTTPMethod.POST
    ) {
      auto tenantId = segments[2];
      res.writeJsonBody(service.authenticate(tenantId, req.json), 200);
      return;
    }

    if (
      segments.length == 4 && segments[0] == "v1" && segments[1] == "tenants" &&
      segments[3] == "auth-events" && req.method == HTTPMethod.GET
    ) {
      auto tenantId = segments[2];
      auto limit = parseSizeT(req.query.get("limit", "100"), 100);
      res.writeJsonBody(service.listAuthEvents(tenantId, limit), 200);
      return;
    }

    respondError(res, "Not found", 404);
  } catch (CDCAuthorizationException e) {
    respondError(res, e.msg, 401);
  } catch (CDCValidationException e) {
    respondError(res, e.msg, 422);
  } catch (CDCNotFoundException e) {
    respondError(res, e.msg, 404);
  } catch (CDCStoreException e) {
    respondError(res, e.msg, 500);
  } catch (CDCException e) {
    respondError(res, e.msg, 500);
  } catch (Exception e) {
    respondError(res, e.msg, 500);
  }
}

private void validateAuth(bool requireAuthToken, string authToken, HTTPServerRequest req) {
  if (!requireAuthToken) return;
  if (!("Authorization" in req.headers)) throw new CDCAuthorizationException("Missing Authorization header");

  auto expected = "Bearer " ~ authToken;
  if (req.headers["Authorization"] != expected) throw new CDCAuthorizationException("Invalid token");
}

private string[] normalizedSegments(string subPath) {
  auto clean = subPath;
  if (clean.length > 0 && clean[0] == '/') clean = clean[1 .. $];
  if (clean.length > 0 && clean[$ - 1] == '/') clean = clean[0 .. $ - 1];
  if (clean.length == 0) return [];
  return clean.split("/");
}

private size_t parseSizeT(string rawValue, size_t fallback) {
  try {
    auto parsed = to!long(rawValue);
    if (parsed < 0) return fallback;
    return cast(size_t)parsed;
  } catch (Exception) {
    return fallback;
  }
}

private void respondError(HTTPServerResponse res, string message, int statusCode) {
  Json payload = Json.emptyObject;
  payload["success"] = false;
  payload["message"] = message;
  payload["status_code"] = statusCode;
  res.writeJsonBody(payload, statusCode);
}
