module uim.sap.servicemanager.server;

import std.array : split;
import std.string : startsWith;

import vibe.data.json : Json;
import vibe.http.common : HTTPMethod;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse, HTTPServerSettings, listenHTTP;

import uim.sap.servicemanager;

mixin(ShowModule!());

@safe:

class SVMServer : SAPServer {
  mixin(SAPServerTemplate!SVMServer);

  private SVMService _service;

  this(SVMService service) {
    _service = service;
  }

  /**
    * Root dispatcher for all incoming HTTP requests.
    *
    * Handles:
    * - Health and readiness checks
    * - Authentication and authorization
    * - Routing to specific handlers based on URL path and HTTP method
    */
  override void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
    super.handleRequest(req, res);

    if (!matchesBasePath(path, basePath)) {
      respondError(res, "Not found", 404);
      return;
    }

    subPath = "/";
    if (path.length > basePath.length) {
      subPath = path[basePath.length .. $];
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
      validateAuth(req, _service.config);

      if (subPath == "/v1/discovery" && req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.discovery(), 200);
        return;
      }

      if (subPath == "/v1/marketplace/offerings" && req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.marketplaceOfferings(), 200);
        return;
      }

      auto segments = normalizedSegments(subPath);
      if (segments.length >= 3 && segments[0] == "v1" && segments[1] == "tenants") {
        auto tenantId = segments[2];

        if (segments.length == 4 && segments[3] == "service-offerings" && req.method == HTTPMethod
          .GET) {
          res.writeJsonBody(_service.serviceOfferings(tenantId), 200);
          return;
        }

        if (segments.length == 4 && segments[3] == "platforms") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listPlatforms(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertPlatform(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "platforms" && req.method == HTTPMethod.DELETE) {
          res.writeJsonBody(_service.deletePlatform(tenantId, segments[4]), 200);
          return;
        }

        if (segments.length == 4 && segments[3] == "service-instances") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listServiceInstances(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertServiceInstance(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "service-instances") {
          auto instanceId = segments[4];
          if (req.method == HTTPMethod.PATCH) {
            res.writeJsonBody(_service.patchServiceInstance(tenantId, instanceId, req.json), 200);
            return;
          }
          if (req.method == HTTPMethod.DELETE) {
            res.writeJsonBody(_service.deleteServiceInstance(tenantId, instanceId), 200);
            return;
          }
        }

        if (segments.length == 6 && segments[3] == "service-instances" && segments[5] == "shares" && req.method == HTTPMethod
          .POST) {
          res.writeJsonBody(_service.shareServiceInstance(tenantId, segments[4], req.json), 200);
          return;
        }

        if (segments.length == 4 && segments[3] == "service-bindings") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listServiceBindings(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertServiceBinding(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "service-bindings" && req.method == HTTPMethod
          .DELETE) {
          res.writeJsonBody(_service.deleteServiceBinding(tenantId, segments[4]), 200);
          return;
        }

        if (segments.length == 7 && segments[3] == "runtime" && segments[4] == "instances" && segments[6] == "actions" && req
          .method == HTTPMethod.POST) {
          respondError(res, "Not found", 404);
          return;
        }

        if (segments.length == 8 && segments[3] == "runtime" && segments[4] == "instances" && segments[6] == "actions" && req
          .method == HTTPMethod.POST) {
          auto instanceId = segments[5];
          auto action = segments[7];
          res.writeJsonBody(_service.runtimeInstanceAction(tenantId, instanceId, action), 200);
          return;
        }
      }

      respondError(res, "Not found", 404);
    } catch (SVMAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (SVMValidationException e) {
      respondError(res, e.msg, 422);
    } catch (SVMNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (SVMException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
    }
  }

  private bool matchesBasePath(string path, string basePath) {
    if (path == basePath) {
      return true;
    }
    return path.startsWith(basePath ~ "/");
  }
}
