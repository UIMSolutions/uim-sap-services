/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.har.server;

import uim.sap.har;
@safe:

class HARServer : SAPServer {
  mixin(SAPServerTemplate!HARServer);
  
  private HARService _service;

  this(HARService service) {
    _service = service;
  }

  override void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
    super.handleRequest(req, res);
    
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
    } catch (HARAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (HARNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (HARValidationException e) {
      respondError(res, e.msg, 422);
    } catch (HARException e) {
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

  private string joinFrom(string[] segments, size_t startIndex) {
    if (segments.length <= startIndex) {
      throw new HARValidationException("Asset path is required");
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
}
