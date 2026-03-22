module uim.sap.jobs.server;


import uim.sap.jobs;

mixin(ShowModule!());

@safe:

class JobSchedulingServer {
  private JobSchedulingService _service;

  this(JobSchedulingService service) {
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

    if (subPath == "/health" && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.health(), 200);
      return;
    }

    if (subPath == "/ready" && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.ready(), 200);
      return;
    }

    if (subPath == "/dashboard" && req.method == HTTPMethod.GET) {
      res.contentType = "text/html; charset=utf-8";
      res.writeBody(_service.dashboardHtml());
      return;
    }

    try {
      validateAuth(req);
      auto segments = normalizedSegments(subPath);

      if (segments.length == 2 && segments[0] == "v1" && segments[1] == "runtimes") {
        if (req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.supportedRuntimes(), 200);
          return;
        }
      }

      if (segments.length == 4 && segments[0] == "v1" && segments[1] == "admin") {
        if (
          segments[2] == "alerts" &&
          segments[3] == "test" &&
          req.method == HTTPMethod.POST
          ) {
          res.writeJsonBody(_service.testAlertConnector(req.json), 200);
          return;
        }

        if (
          segments[2] == "cloud-alm" &&
          segments[3] == "test" &&
          req.method == HTTPMethod.POST
          ) {
          res.writeJsonBody(_service.testCloudAlmConnector(req.json), 200);
          return;
        }
      }

      if (segments.length >= 3 && segments[0] == "v1" && segments[1] == "tenants") {
        auto tenantId = segments[2];

        if (segments.length == 4 && segments[3] == "jobs") {
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createJob(tenantId, req.json), 200);
            return;
          }
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listJobs(tenantId), 200);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "jobs") {
          auto jobId = segments[4];
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getJob(tenantId, jobId), 200);
            return;
          }
          if (req.method == HTTPMethod.PUT) {
            res.writeJsonBody(_service.updateJob(tenantId, jobId, req.json), 200);
            return;
          }
          if (req.method == HTTPMethod.DELETE) {
            res.writeJsonBody(_service.deleteJob(tenantId, jobId), 200);
            return;
          }
        }

        if (
          segments.length == 6 &&
          segments[3] == "jobs" &&
          segments[5] == "run" &&
          req.method == HTTPMethod.POST
          ) {
          res.writeJsonBody(_service.runJobNow(tenantId, segments[4], req.json), 200);
          return;
        }

        if (segments.length == 4 && segments[3] == "schedules") {
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createSchedule(tenantId, req.json), 200);
            return;
          }
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listSchedules(tenantId), 200);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "schedules") {
          auto scheduleId = segments[4];
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getSchedule(tenantId, scheduleId), 200);
            return;
          }
          if (req.method == HTTPMethod.PUT) {
            res.writeJsonBody(_service.updateSchedule(tenantId, scheduleId, req.json), 200);
            return;
          }
          if (req.method == HTTPMethod.DELETE) {
            res.writeJsonBody(_service.deleteSchedule(tenantId, scheduleId), 200);
            return;
          }
        }

        if (segments.length == 4 && segments[3] == "runs" && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.listRuns(tenantId), 200);
          return;
        }

        if (segments.length == 4 && segments[3] == "alerts" && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.listAlerts(tenantId), 200);
          return;
        }

        if (
          segments.length == 6 &&
          segments[3] == "tasks" &&
          segments[4] == "cf" &&
          segments[5] == "run" &&
          req.method == HTTPMethod.POST
          ) {
          res.writeJsonBody(_service.runCFTask(tenantId, req.json), 200);
          return;
        }

        if (
          segments.length == 6 &&
          segments[3] == "tasks" &&
          segments[4] == "cf" &&
          segments[5] == "runs" &&
          req.method == HTTPMethod.GET
          ) {
          res.writeJsonBody(_service.listCFTaskRuns(tenantId), 200);
          return;
        }

        if (
          segments.length == 4 &&
          segments[3] == "dashboard" &&
          req.method == HTTPMethod.GET
          ) {
          res.writeJsonBody(_service.dashboardData(tenantId), 200);
          return;
        }
      }

      respondError(res, "Not found", 404);
    } catch (JobSchedulingAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (JobSchedulingNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (JobSchedulingValidationException e) {
      respondError(res, e.msg, 422);
    } catch (JobSchedulingException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
    }
  }

  private void validateAuth(HTTPServerRequest req) {
    if (!_service.config.requireAuthToken)
      return;

    if (!("Authorization" in req.headers)) {
      throw new JobSchedulingAuthorizationException("Missing Authorization header");
    }

    auto expected = "Bearer " ~ _service.config.authToken;
    if (req.headers["Authorization"] != expected) {
      throw new JobSchedulingAuthorizationException("Invalid token");
    }
  }
}
