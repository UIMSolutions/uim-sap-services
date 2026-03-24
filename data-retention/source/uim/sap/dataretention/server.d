module uim.sap.dataretention.server;

import std.array : split;
import std.string : startsWith;

import vibe.data.json : Json;
import vibe.http.common : HTTPMethod;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse, HTTPServerSettings, listenHTTP;

import uim.sap.dataretention;

mixin(ShowModule!());

@safe:

class DRMServer : SAPServer {
  mixin(SAPServerTemplate!DRMServer);

  private DRMService _service;

  this(DRMService service) {
    _service = service;
  }

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

      auto segments = normalizedSegments(subPath);
      if (segments.length >= 3 && segments[0] == "v1" && segments[1] == "tenants") {
        auto tenantId = segments[2];

        if (segments.length == 4 && segments[3] == "business-purposes") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listBusinessPurposes(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertBusinessPurpose(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 4 && segments[3] == "retention-rules") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listRetentionRules(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertRetentionRule(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 4 && segments[3] == "jobs" && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.listJobs(tenantId), 200);
          return;
        }

        if (segments.length == 4 && segments[3] == "archive-jobs" && req.method == HTTPMethod.POST) {
          res.writeJsonBody(_service.createArchiveJob(tenantId, req.json), 200);
          return;
        }

        if (segments.length == 4 && segments[3] == "destruction-jobs" && req.method == HTTPMethod.POST) {
          res.writeJsonBody(_service.createDestructionJob(tenantId, req.json), 200);
          return;
        }

        if (segments.length == 4 && segments[3] == "data-subjects" && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.listDataSubjects(tenantId), 200);
          return;
        }

        if (segments.length == 5 && segments[3] == "data-subjects" && req.method == HTTPMethod.POST) {
          auto dataSubjectId = segments[4];
          res.writeJsonBody(_service.upsertDataSubject(tenantId, dataSubjectId, req.json), 200);
          return;
        }

        if (segments.length == 6 && segments[3] == "data-subjects" && segments[5] == "evaluate" && req.method == HTTPMethod.POST) {
          auto dataSubjectId = segments[4];
          res.writeJsonBody(_service.evaluateDataSubject(tenantId, dataSubjectId), 200);
          return;
        }
      }

      respondError(res, "Not found", 404);
    } catch (DRMAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (DRMValidationException e) {
      respondError(res, e.msg, 422);
    } catch (DRMNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (DRMException e) {
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