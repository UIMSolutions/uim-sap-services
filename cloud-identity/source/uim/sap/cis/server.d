/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cis.server;

import uim.sap.cis;

mixin(ShowModule!());

@safe:

class CISServer {
  private CISService _service;

  this(CISService service) {
    _service = service;
  }

  void run() {
    auto settings = new HTTPServerSettings;
    settings.port = _service.config.port;
    settings.bindAddresses = [_service.config.host];
    listenHTTP(settings, &handleRequest);
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

    try {
      validateAuth(req);

      if (subPath == "/v1/auth/capabilities" && req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.authenticationCapabilities(), 200);
        return;
      }

      auto segments = normalizedSegments(subPath);
      if (segments.length >= 3 && segments[0] == "v1" && segments[1] == "tenants") {
        auto tenantId = segments[2];

        if (segments.length == 5 && segments[3] == "auth" && segments[4] == "login" && req.method == HTTPMethod
          .POST) {
          res.writeJsonBody(_service.login(tenantId, req.json), 200);
          return;
        }

        if (segments.length == 5 && segments[3] == "scim" && segments[4] == "Users") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listUsers(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertUser(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "scim" && segments[4] == "Groups") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listGroups(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.upsertGroup(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "users" && segments[4] == "invite" && req.method == HTTPMethod
          .POST) {
          res.writeJsonBody(_service.inviteUser(tenantId, req.json), 200);
          return;
        }

        if (segments.length == 6 && segments[3] == "ui-texts" && req.method == HTTPMethod.PUT) {
          auto locale = segments[4];
          res.writeJsonBody(_service.setUiText(tenantId, locale, req.json), 200);
          return;
        }

        if (segments.length == 4 && segments[3] == "delegation-rules" && req.method == HTTPMethod
          .GET) {
          res.writeJsonBody(_service.listDelegationRules(tenantId), 200);
          return;
        }

        if (segments.length == 5 && segments[3] == "delegation-rules" && req.method == HTTPMethod
          .PUT) {
          auto ruleId = segments[4];
          res.writeJsonBody(_service.upsertDelegationRule(tenantId, ruleId, req.json), 200);
          return;
        }

        if (segments.length == 4 && segments[3] == "policies" && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.listPolicies(tenantId), 200);
          return;
        }

        if (segments.length == 5 && segments[3] == "policies" && req.method == HTTPMethod.PUT) {
          auto policyId = segments[4];
          res.writeJsonBody(_service.upsertPolicy(tenantId, policyId, req.json), 200);
          return;
        }

        if (segments.length == 5 && segments[3] == "policies" && segments[4] == "authorize" && req.method == HTTPMethod
          .POST) {
          res.writeJsonBody(_service.authorize(tenantId, req.json), 200);
          return;
        }

        if (segments.length == 4 && segments[3] == "risk-policies" && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.listRiskPolicies(tenantId), 200);
          return;
        }

        if (segments.length == 5 && segments[3] == "risk-policies" && req.method == HTTPMethod.PUT) {
          auto policyId = segments[4];
          res.writeJsonBody(_service.upsertRiskPolicy(tenantId, policyId, req.json), 200);
          return;
        }

        if (segments.length == 5 && segments[3] == "risk" && segments[4] == "evaluate" && req.method == HTTPMethod
          .POST) {
          res.writeJsonBody(_service.evaluateRisk(tenantId, req.json), 200);
          return;
        }

        if (segments.length == 5 && segments[3] == "provisioning" && segments[4] == "jobs") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listProvisioningJobs(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.startProvisioningJob(tenantId, req.json), 200);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "provisioning" && segments[4] == "logs" && req.method == HTTPMethod
          .GET) {
          res.writeJsonBody(_service.listJobLogs(tenantId), 200);
          return;
        }

        if (segments.length == 5 && segments[3] == "provisioning" && segments[4] == "subscriptions") {
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listNotificationSubscriptions(tenantId), 200);
            return;
          }
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.subscribeNotifications(tenantId, req.json), 200);
            return;
          }
        }
      }

      respondError(res, "Not found", 404);
    } catch (CISAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (CISNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (CISValidationException e) {
      respondError(res, e.msg, 422);
    } catch (CISException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
    }
  }

  private void validateAuth(HTTPServerRequest req) {
    if (!_service.config.requireAuthToken)
      return;
    if (!("Authorization" in req.headers))
      throw new CISAuthorizationException("Missing Authorization header");
    auto expected = "Bearer " ~ _service.config.authToken;
    if (req.headers["Authorization"] != expected)
      throw new CISAuthorizationException("Invalid token");
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
