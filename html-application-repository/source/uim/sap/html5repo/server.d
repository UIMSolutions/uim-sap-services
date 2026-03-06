module uim.sap.html5repo.server;

import uim.sap.html5repo;
@safe:

class HTMRepoServer : SAPServer {
  mixin(SAPServerTemplate!HTMRepoServer);
  
  private HTMRepoService _service;

  this(HTMRepoService service) {
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
    foreach (key, value; _service.config.customHeaders) {
      res.headers[key] = value;
    }

    auto basePath = _service.config.basePath;
    auto path = req.path;
    if (!path.startsWith(basePath)) {
      respondError(res, "Not found", 404);
      return;
    }

    auto subPath = path[basePath.length .. $];
    if (subPath.length == 0) {
      subPath = "/";
    }

    if (subPath == "/health" && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.health(), 200);
      return;
    }

    if (subPath == "/ready" && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.ready(), 200);
      return;
    }

    try {
      if (subPath.startsWith("/v1/")) {
        validateManagementAuth(req);
        routeManagement(req, res, subPath);
        return;
      }

      if (subPath.startsWith("/runtime/")) {
        routeRuntime(req, res, subPath);
        return;
      }

      respondError(res, "Not found", 404);
    } catch (HTMRepoAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (HTMRepoNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (HTMRepoValidationException e) {
      respondError(res, e.msg, 422);
    } catch (HTMRepoException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
    }
  }

  private void routeManagement(HTTPServerRequest req, HTTPServerResponse res, string subPath) {
    auto segments = normalizedSegments(subPath);
    auto tenant = tenantFromHeaders(req);

    if (segments.length == 2 && segments[0] == "v1" && segments[1] == "apps" && req.method == HTTPMethod
      .GET) {
      res.writeJsonBody(_service.listApplications(tenant), 200);
      return;
    }

    if (
      segments.length == 4 && segments[0] == "v1" && segments[1] == "apps" &&
      segments[3] == "versions" && req.method == HTTPMethod.GET
      ) {
      res.writeJsonBody(_service.listVersions(tenant, segments[2]), 200);
      return;
    }

    if (
      segments.length == 4 && segments[0] == "v1" && segments[1] == "apps" &&
      segments[3] == "active" && req.method == HTTPMethod.GET
      ) {
      res.writeJsonBody(_service.activeVersion(tenant, segments[2]), 200);
      return;
    }

    if (
      segments.length == 6 && segments[0] == "v1" && segments[1] == "apps" &&
      segments[3] == "versions" && segments[5] == "files" &&
      req.method == HTTPMethod.GET
      ) {
      res.writeJsonBody(_service.listFiles(tenant, segments[2], segments[4]), 200);
      return;
    }

    if (
      segments.length == 5 && segments[0] == "v1" && segments[1] == "apps" &&
      segments[3] == "versions" && req.method == HTTPMethod.POST
      ) {
      res.writeJsonBody(_service.uploadVersion(tenant, segments[2], segments[4], req.json), 201);
      return;
    }

    if (
      segments.length == 6 && segments[0] == "v1" && segments[1] == "apps" &&
      segments[3] == "versions" && segments[5] == "activate" &&
      req.method == HTTPMethod.POST
      ) {
      res.writeJsonBody(_service.activateVersion(tenant, segments[2], segments[4]), 200);
      return;
    }

    if (
      segments.length == 5 && segments[0] == "v1" && segments[1] == "apps" &&
      segments[3] == "versions" && req.method == HTTPMethod.DELETE
      ) {
      res.writeJsonBody(_service.deleteVersion(tenant, segments[2], segments[4]), 200);
      return;
    }

    respondError(res, "Not found", 404);
  }

  private void routeRuntime(HTTPServerRequest req, HTTPServerResponse res, string subPath) {
    if (req.method != HTTPMethod.GET) {
      respondError(res, "Method not allowed", 405);
      return;
    }

    auto segments = normalizedSegments(subPath);
    if (segments.length < 7 || segments[0] != "runtime") {
      respondError(res, "Not found", 404);
      return;
    }

    auto tenantId = segments[1];
    auto spaceId = segments[2];
    auto appId = segments[3];

    auto consumerTenant = req.headers.get("X-Consumer-Tenant-ID", tenantId);
    auto consumerSpace = req.headers.get("X-Consumer-Space-ID", spaceId);

    RuntimeAsset asset;
    if (segments[4] == "active") {
      auto assetPath = joinFrom(segments, 5);
      asset = _service.runtimeAssetByActiveVersion(
        tenantId,
        spaceId,
        appId,
        assetPath,
        consumerTenant,
        consumerSpace
      );
    } else if (segments[4] == "versions") {
      auto versionId = segments[5];
      auto assetPath = joinFrom(segments, 6);
      asset = _service.runtimeAssetByVersion(
        tenantId,
        spaceId,
        appId,
        versionId,
        assetPath,
        consumerTenant,
        consumerSpace
      );
    } else {
      respondError(res, "Not found", 404);
      return;
    }

    res.headers["ETag"] = asset.etag;
    res.headers["Cache-Control"] = "public, max-age=" ~ to!string(_service.config.cacheTtlSeconds);
    res.statusCode = 200;
    res.writeBody(cast(const(ubyte)[])asset.content, asset.contentType);
  }

  private TenantContext tenantFromHeaders(HTTPServerRequest req) {
    TenantContext tenant;
    tenant.tenantId = req.headers.get("X-Tenant-ID", _service.config.defaultTenant);
    tenant.spaceId = req.headers.get("X-Space-ID", _service.config.defaultSpace);
    tenant.consumerTenantId = tenant.tenantId;
    tenant.consumerSpaceId = tenant.spaceId;
    return tenant;
  }

  private void validateManagementAuth(HTTPServerRequest req) {
    if (!_service.config.requireManagementAuth) {
      return;
    }

    if (!("Authorization" in req.headers)) {
      throw new HTMRepoAuthorizationException("Missing Authorization header");
    }

    auto expected = "Bearer " ~ _service.config.managementAuthToken;
    if (req.headers["Authorization"] != expected) {
      throw new HTMRepoAuthorizationException("Invalid management token");
    }
  }

  private string[] normalizedSegments(string subPath) {
    auto clean = subPath;
    if (clean.length > 0 && clean[0] == '/') {
      clean = clean[1 .. $];
    }
    if (clean.length > 0 && clean[$ - 1] == '/') {
      clean = clean[0 .. $ - 1];
    }
    if (clean.length == 0) {
      return [];
    }
    return clean.split("/");
  }

  private string joinFrom(string[] segments, size_t startIndex) {
    if (segments.length <= startIndex) {
      throw new HTMRepoValidationException("Asset path is required");
    }

    string resultPath;
    foreach (index; startIndex .. segments.length) {
      if (resultPath.length > 0) {
        resultPath ~= "/";
      }
      resultPath ~= segments[index];
    }
    return resultPath;
  }

  private void respondError(HTTPServerResponse res, string message, int statusCode) {
    Json payload = Json.emptyObject;
    payload["success"] = false;
    payload["message"] = message;
    payload["status_code"] = statusCode;
    res.writeJsonBody(payload, statusCode);
  }
}
