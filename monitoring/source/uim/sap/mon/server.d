/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.mon.server;

import uim.sap.mon;

mixin(ShowModule!());

@safe:

class MONServer : SAPServer {
  mixin(SAPServerTemplate!MONServer);
  
  private MONService _service;

  this(MONService service) {
    _service = service;
  }

  override void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
  super.handleRequest(req, res);



    if (!path.startsWith(basePath)) {
      respondError(res, "Not found", 404);
      return;
    }

    auto subPath = path[basePath.length .. $];
    if (subPath.length == 0) {
      subPath = "/";
    }

    try {
      if (subPath == "/health" && req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.health(), 200);
        return;
      }

      if (subPath == "/ready" && req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.ready(), 200);
        return;
      }

      validateAuth(req, _service.config);

      auto segments = normalizedSegments(subPath);

      if (segments.length == 4 &&
        segments[0] == "v1" &&
        segments[1] == "applications" &&
        segments[3] == "metrics" &&
        req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.fetchApplicationMetrics(segments[2]), 200);
        return;
      }

      if (segments.length == 4 &&
        segments[0] == "v1" &&
        segments[1] == "databases" &&
        segments[3] == "metrics" &&
        req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.fetchDatabaseMetrics(segments[2]), 200);
        return;
      }

      if (segments.length == 5 &&
        segments[0] == "v1" &&
        segments[1] == "metrics" &&
        segments[2] == "history" &&
        req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.metricHistory(segments[3], segments[4]), 200);
        return;
      }

      if (segments.length == 3 &&
        segments[0] == "v1" &&
        segments[1] == "checks" &&
        segments[2] == "availability" &&
        req.method == HTTPMethod.POST) {
        res.writeJsonBody(_service.registerAvailabilityCheck(req.json), 201);
        return;
      }

      if (segments.length == 4 &&
        segments[0] == "v1" &&
        segments[1] == "alerts" &&
        segments[2] == "channels" &&
        segments[3] == "email" &&
        req.method == HTTPMethod.PUT) {
        res.writeJsonBody(_service.setAlertEmailChannel(req.json), 200);
        return;
      }

      if (segments.length == 4 &&
        segments[0] == "v1" &&
        segments[1] == "alerts" &&
        segments[2] == "channels" &&
        segments[3] == "webhook" &&
        req.method == HTTPMethod.PUT) {
        res.writeJsonBody(_service.setAlertWebhookChannel(req.json), 200);
        return;
      }

      if (segments.length == 3 &&
        segments[0] == "v1" &&
        segments[1] == "alerts" &&
        segments[2] == "channels" &&
        req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.getAlertChannels(), 200);
        return;
      }

      if (segments.length == 3 &&
        segments[0] == "v1" &&
        segments[1] == "checks" &&
        segments[2] == "jmx" &&
        req.method == HTTPMethod.POST) {
        res.writeJsonBody(_service.configureJMXCheck(req.json), 201);
        return;
      }

      if (segments.length == 3 &&
        segments[0] == "v1" &&
        segments[1] == "jmx" &&
        segments[2] == "operations" &&
        req.method == HTTPMethod.POST) {
        res.writeJsonBody(_service.performJMXOperation(req.json), 200);
        return;
      }

      if (segments.length == 3 &&
        segments[0] == "v1" &&
        segments[1] == "checks" &&
        segments[2] == "custom" &&
        req.method == HTTPMethod.POST) {
        res.writeJsonBody(_service.registerCustomCheck(req.json), 201);
        return;
      }

      if (segments.length == 5 &&
        segments[0] == "v1" &&
        segments[1] == "checks" &&
        segments[2] == "default" &&
        segments[4] == "thresholds") {
        if (req.method == HTTPMethod.PUT) {
          res.writeJsonBody(_service.overrideDefaultThreshold(segments[3], req.json), 200);
          return;
        }
        if (req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.getThresholdOverride(segments[3]), 200);
          return;
        }
      }

      respondError(res, "Not found", 404);
    } catch (MONAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (MONNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (MONValidationException e) {
      respondError(res, e.msg, 422);
    } catch (MONException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
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
      return null;
    }
    return clean.split("/");
  }

}
