module uim.sap.kym.server;

import std.array : split;
import std.string : startsWith;

import vibe.data.json : Json;
import vibe.http.common : HTTPMethod;
import vibe.http.server : HTTPServerRequest, HTTPServerResponse, HTTPServerSettings, listenHTTP;

import uim.sap.kym.exceptions;
import uim.sap.kym.service;

/**
 * HTTP server for the Kyma Runtime Service.
 *
 * Routes:
 *   GET  /health
 *   GET  /ready
 *   GET  /v1/metrics
 *
 *   Namespaces:
 *     GET    /v1/namespaces
 *     POST   /v1/namespaces/{ns}
 *     PUT    /v1/namespaces/{ns}
 *     GET    /v1/namespaces/{ns}
 *     DELETE /v1/namespaces/{ns}
 *
 *   Functions:
 *     GET    /v1/namespaces/{ns}/functions
 *     POST   /v1/namespaces/{ns}/functions/{name}
 *     PUT    /v1/namespaces/{ns}/functions/{name}
 *     GET    /v1/namespaces/{ns}/functions/{name}
 *     DELETE /v1/namespaces/{ns}/functions/{name}
 *     POST   /v1/namespaces/{ns}/functions/{name}/invoke
 *
 *   Microservices:
 *     GET    /v1/namespaces/{ns}/microservices
 *     POST   /v1/namespaces/{ns}/microservices/{name}
 *     PUT    /v1/namespaces/{ns}/microservices/{name}
 *     GET    /v1/namespaces/{ns}/microservices/{name}
 *     DELETE /v1/namespaces/{ns}/microservices/{name}
 *     POST   /v1/namespaces/{ns}/microservices/{name}/scale
 *
 *   Events:
 *     POST   /v1/namespaces/{ns}/events
 *
 *   Subscriptions:
 *     GET    /v1/namespaces/{ns}/subscriptions
 *     POST   /v1/namespaces/{ns}/subscriptions
 *     GET    /v1/namespaces/{ns}/subscriptions/{id}
 *     DELETE /v1/namespaces/{ns}/subscriptions/{id}
 *
 *   API Rules:
 *     GET    /v1/namespaces/{ns}/api-rules
 *     POST   /v1/namespaces/{ns}/api-rules/{name}
 *     PUT    /v1/namespaces/{ns}/api-rules/{name}
 *     GET    /v1/namespaces/{ns}/api-rules/{name}
 *     DELETE /v1/namespaces/{ns}/api-rules/{name}
 *
 *   Service Bindings:
 *     GET    /v1/namespaces/{ns}/service-bindings
 *     POST   /v1/namespaces/{ns}/service-bindings/{name}
 *     GET    /v1/namespaces/{ns}/service-bindings/{name}
 *     DELETE /v1/namespaces/{ns}/service-bindings/{name}
 */
class KYMServer : SAPServer {
  mixin(SAPServerTemplate!KYMServer);

  private KYMService _service;

  this(KYMService service) {
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

    try {
      validateAuth(req, _service.config);
      auto segments = normalizedSegments(subPath);

      // GET /v1/metrics
      if (segments.length == 2 && segments[0] == "v1" && segments[1] == "metrics" && req.method == HTTPMethod
        .GET) {
        res.writeJsonBody(_service.getMetrics(), 200);
        return;
      }

      // /v1/namespaces...
      if (segments.length >= 2 && segments[0] == "v1" && segments[1] == "namespaces") {
        routeNamespaces(req, res, segments[2 .. $]);
        return;
      }

      respondError(res, "Not found", 404);
    } catch (KYMAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (KYMConflictException e) {
      respondError(res, e.msg, 409);
    } catch (KYMNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (KYMQuotaExceededException e) {
      respondError(res, e.msg, 429);
    } catch (KYMValidationException e) {
      respondError(res, e.msg, 422);
    } catch (KYMException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
    }
  }

  private void routeNamespaces(HTTPServerRequest req, HTTPServerResponse res, string[] segments) {
    // GET /v1/namespaces
    if (segments.length == 0 && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.listNamespaces(), 200);
      return;
    }
    if (segments.length == 0) {
      respondError(res, "Not found", 404);
      return;
    }

    auto ns = segments[0];

    // POST /v1/namespaces/{ns}
    if (segments.length == 1 && req.method == HTTPMethod.POST) {
      res.writeJsonBody(_service.createNamespace(ns, req.json), 201);
      return;
    }
    // PUT /v1/namespaces/{ns}
    if (segments.length == 1 && req.method == HTTPMethod.PUT) {
      res.writeJsonBody(_service.updateNamespace(ns, req.json), 200);
      return;
    }
    // GET /v1/namespaces/{ns}
    if (segments.length == 1 && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.getNamespace(ns), 200);
      return;
    }
    // DELETE /v1/namespaces/{ns}
    if (segments.length == 1 && req.method == HTTPMethod.DELETE) {
      res.writeJsonBody(_service.deleteNamespace(ns), 200);
      return;
    }

    // Sub-resources within a namespace
    if (segments.length >= 2) {
      auto resource = segments[1];

      if (resource == "functions") {
        routeFunctions(req, res, ns, segments[2 .. $]);
        return;
      }
      if (resource == "microservices") {
        routeMicroservices(req, res, ns, segments[2 .. $]);
        return;
      }
      if (resource == "events") {
        routeEvents(req, res, ns, segments[2 .. $]);
        return;
      }
      if (resource == "subscriptions") {
        routeSubscriptions(req, res, ns, segments[2 .. $]);
        return;
      }
      if (resource == "api-rules") {
        routeApiRules(req, res, ns, segments[2 .. $]);
        return;
      }
      if (resource == "service-bindings") {
        routeServiceBindings(req, res, ns, segments[2 .. $]);
        return;
      }
    }

    respondError(res, "Not found", 404);
  }

  // ── Functions ──

  private void routeFunctions(HTTPServerRequest req, HTTPServerResponse res, string ns, string[] segments) {
    // GET /v1/namespaces/{ns}/functions
    if (segments.length == 0 && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.listFunctions(ns), 200);
      return;
    }
    if (segments.length == 0) {
      respondError(res, "Not found", 404);
      return;
    }

    auto name = segments[0];

    // POST /v1/namespaces/{ns}/functions/{name}/invoke
    if (segments.length == 2 && segments[1] == "invoke" && req.method == HTTPMethod.POST) {
      res.writeJsonBody(_service.invokeFunction(ns, name, req.json), 200);
      return;
    }

    // POST /v1/namespaces/{ns}/functions/{name}
    if (segments.length == 1 && req.method == HTTPMethod.POST) {
      res.writeJsonBody(_service.createFunction(ns, name, req.json), 201);
      return;
    }
    // PUT /v1/namespaces/{ns}/functions/{name}
    if (segments.length == 1 && req.method == HTTPMethod.PUT) {
      res.writeJsonBody(_service.updateFunction(ns, name, req.json), 200);
      return;
    }
    // GET /v1/namespaces/{ns}/functions/{name}
    if (segments.length == 1 && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.getFunction(ns, name), 200);
      return;
    }
    // DELETE /v1/namespaces/{ns}/functions/{name}
    if (segments.length == 1 && req.method == HTTPMethod.DELETE) {
      res.writeJsonBody(_service.deleteFunction(ns, name), 200);
      return;
    }

    respondError(res, "Not found", 404);
  }

  // ── Microservices ──

  private void routeMicroservices(HTTPServerRequest req, HTTPServerResponse res, string ns, string[] segments) {
    if (segments.length == 0 && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.listMicroservices(ns), 200);
      return;
    }
    if (segments.length == 0) {
      respondError(res, "Not found", 404);
      return;
    }

    auto name = segments[0];

    // POST /v1/namespaces/{ns}/microservices/{name}/scale
    if (segments.length == 2 && segments[1] == "scale" && req.method == HTTPMethod.POST) {
      res.writeJsonBody(_service.scaleMicroservice(ns, name, req.json), 200);
      return;
    }

    if (segments.length == 1 && req.method == HTTPMethod.POST) {
      res.writeJsonBody(_service.createMicroservice(ns, name, req.json), 201);
      return;
    }
    if (segments.length == 1 && req.method == HTTPMethod.PUT) {
      res.writeJsonBody(_service.updateMicroservice(ns, name, req.json), 200);
      return;
    }
    if (segments.length == 1 && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.getMicroservice(ns, name), 200);
      return;
    }
    if (segments.length == 1 && req.method == HTTPMethod.DELETE) {
      res.writeJsonBody(_service.deleteMicroservice(ns, name), 200);
      return;
    }

    respondError(res, "Not found", 404);
  }

  // ── Events ──

  private void routeEvents(HTTPServerRequest req, HTTPServerResponse res, string ns, string[] segments) {
    // POST /v1/namespaces/{ns}/events
    if (segments.length == 0 && req.method == HTTPMethod.POST) {
      res.writeJsonBody(_service.publishEvent(ns, req.json), 200);
      return;
    }

    respondError(res, "Not found", 404);
  }

  // ── Subscriptions ──

  private void routeSubscriptions(HTTPServerRequest req, HTTPServerResponse res, string ns, string[] segments) {
    // GET /v1/namespaces/{ns}/subscriptions
    if (segments.length == 0 && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.listSubscriptions(ns), 200);
      return;
    }
    // POST /v1/namespaces/{ns}/subscriptions  (id auto-generated)
    if (segments.length == 0 && req.method == HTTPMethod.POST) {
      res.writeJsonBody(_service.createSubscription(ns, req.json), 201);
      return;
    }

    if (segments.length >= 1) {
      auto id = segments[0];

      if (segments.length == 1 && req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.getSubscription(ns, id), 200);
        return;
      }
      if (segments.length == 1 && req.method == HTTPMethod.DELETE) {
        res.writeJsonBody(_service.deleteSubscription(ns, id), 200);
        return;
      }
    }

    respondError(res, "Not found", 404);
  }

  // ── API Rules ──

  private void routeApiRules(HTTPServerRequest req, HTTPServerResponse res, string ns, string[] segments) {
    if (segments.length == 0 && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.listApiRules(ns), 200);
      return;
    }
    if (segments.length == 0) {
      respondError(res, "Not found", 404);
      return;
    }

    auto name = segments[0];

    if (segments.length == 1 && req.method == HTTPMethod.POST) {
      res.writeJsonBody(_service.createApiRule(ns, name, req.json), 201);
      return;
    }
    if (segments.length == 1 && req.method == HTTPMethod.PUT) {
      res.writeJsonBody(_service.updateApiRule(ns, name, req.json), 200);
      return;
    }
    if (segments.length == 1 && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.getApiRule(ns, name), 200);
      return;
    }
    if (segments.length == 1 && req.method == HTTPMethod.DELETE) {
      res.writeJsonBody(_service.deleteApiRule(ns, name), 200);
      return;
    }

    respondError(res, "Not found", 404);
  }

  // ── Service Bindings ──

  private void routeServiceBindings(HTTPServerRequest req, HTTPServerResponse res, string ns, string[] segments) {
    if (segments.length == 0 && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.listServiceBindings(ns), 200);
      return;
    }
    if (segments.length == 0) {
      respondError(res, "Not found", 404);
      return;
    }

    auto name = segments[0];

    if (segments.length == 1 && req.method == HTTPMethod.POST) {
      res.writeJsonBody(_service.createServiceBinding(ns, name, req.json), 201);
      return;
    }
    if (segments.length == 1 && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.getServiceBinding(ns, name), 200);
      return;
    }
    if (segments.length == 1 && req.method == HTTPMethod.DELETE) {
      res.writeJsonBody(_service.deleteServiceBinding(ns, name), 200);
      return;
    }

    respondError(res, "Not found", 404);
  }
}
