module uim.sap.eventmesh.server;

import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:

/**
 * EMServer is responsible for handling HTTP requests and routing them to the appropriate service methods.
 *
 * It listens on the configured host and port, and supports the following endpoints:
 *
 * Platform:
 * - GET  /health
 * - GET  /ready
 *
 * Queues:
 * - POST /v1/tenants/{tenantId}/queues                              Create queue
 * - GET  /v1/tenants/{tenantId}/queues                              List queues
 * - GET  /v1/tenants/{tenantId}/queues/{queueName}                  Get queue details
 * - DELETE /v1/tenants/{tenantId}/queues/{queueName}                Delete queue
 * - GET  /v1/tenants/{tenantId}/queues/{queueName}/messages         List messages in queue
 * - POST /v1/tenants/{tenantId}/queues/{queueName}/consume          Consume next message
 * - POST /v1/tenants/{tenantId}/queues/{queueName}/ack/{messageId}  Acknowledge message
 * - GET  /v1/tenants/{tenantId}/queues/{queueName}/deadletters      List dead letters
 *
 * Topics:
 * - POST /v1/tenants/{tenantId}/topics                              Create topic
 * - GET  /v1/tenants/{tenantId}/topics                              List topics
 * - POST /v1/tenants/{tenantId}/topics/{topicName}/publish          Publish event
 *
 * Subscriptions:
 * - POST /v1/tenants/{tenantId}/subscriptions                       Create subscription
 * - GET  /v1/tenants/{tenantId}/subscriptions                       List subscriptions
 *
 * Webhooks:
 * - POST /v1/tenants/{tenantId}/webhooks                            Register webhook
 * - GET  /v1/tenants/{tenantId}/webhooks                            List webhooks
 * - DELETE /v1/tenants/{tenantId}/webhooks/{webhookId}              Delete webhook
 *
 * Dashboard:
 * - GET  /v1/tenants/{tenantId}/dashboard                           Get dashboard metrics
 */
class EMServer {
  private EMService _service;

  this(EMService service) {
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

    // --- Platform endpoints ---
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

      // All business routes are under /v1/tenants/{tenantId}/...
      if (segments.length >= 3 && segments[0] == "v1" && segments[1] == "tenants") {
        auto tenantId = segments[2];

        // --- Queue routes ---
        if (segments.length == 4 && segments[3] == "queues") {
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createQueue(tenantId, req.json), 201);
            return;
          }
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listQueues(tenantId), 200);
            return;
          }
        }

        if (segments.length == 5 && segments[3] == "queues") {
          auto queueName = segments[4];
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.getQueue(tenantId, queueName), 200);
            return;
          }
          if (req.method == HTTPMethod.DELETE) {
            res.writeJsonBody(_service.deleteQueue(tenantId, queueName), 200);
            return;
          }
        }

        if (segments.length == 6 && segments[3] == "queues") {
          auto queueName = segments[4];

          if (segments[5] == "messages" && req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listQueueMessages(tenantId, queueName), 200);
            return;
          }

          if (segments[5] == "consume" && req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.consumeMessage(tenantId, queueName), 200);
            return;
          }

          if (segments[5] == "deadletters" && req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listDeadLetters(tenantId, queueName), 200);
            return;
          }
        }

        if (segments.length == 7
          && segments[3] == "queues"
          && segments[5] == "ack"
          && req.method == HTTPMethod.POST) {
          auto queueName = segments[4];
          auto messageId = segments[6];
          res.writeJsonBody(_service.acknowledgeMessage(tenantId, queueName, messageId), 200);
          return;
        }

        // --- Topic routes ---
        if (segments.length == 4 && segments[3] == "topics") {
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createTopic(tenantId, req.json), 201);
            return;
          }
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listTopics(tenantId), 200);
            return;
          }
        }

        if (segments.length == 6
          && segments[3] == "topics"
          && segments[5] == "publish"
          && req.method == HTTPMethod.POST) {
          auto topicName = segments[4];
          res.writeJsonBody(_service.publishMessage(tenantId, topicName, req.json), 200);
          return;
        }

        // --- Subscription routes ---
        if (segments.length == 4 && segments[3] == "subscriptions") {
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.createSubscription(tenantId, req.json), 201);
            return;
          }
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listSubscriptions(tenantId), 200);
            return;
          }
        }

        // --- Webhook routes ---
        if (segments.length == 4 && segments[3] == "webhooks") {
          if (req.method == HTTPMethod.POST) {
            res.writeJsonBody(_service.registerWebhook(tenantId, req.json), 201);
            return;
          }
          if (req.method == HTTPMethod.GET) {
            res.writeJsonBody(_service.listWebhooks(tenantId), 200);
            return;
          }
        }

        if (segments.length == 5
          && segments[3] == "webhooks"
          && req.method == HTTPMethod.DELETE) {
          auto webhookId = segments[4];
          res.writeJsonBody(_service.deleteWebhook(tenantId, webhookId), 200);
          return;
        }

        // --- Dashboard ---
        if (segments.length == 4
          && segments[3] == "dashboard"
          && req.method == HTTPMethod.GET) {
          res.writeJsonBody(_service.dashboard(tenantId), 200);
          return;
        }
      }

      respondError(res, "Not found", 404);
    } catch (EMAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (EMNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (EMValidationException e) {
      respondError(res, e.msg, 422);
    } catch (EMException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
    }
  }

  private void validateAuth(HTTPServerRequest req) {
    if (!_service.config.requireAuthToken) {
      return;
    }

    if (!("Authorization" in req.headers)) {
      throw new EMAuthorizationException("Missing Authorization header");
    }

    auto expected = "Bearer " ~ _service.config.authToken;
    if (req.headers["Authorization"] != expected) {
      throw new EMAuthorizationException("Invalid token");
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

  private void respondError(HTTPServerResponse res, string message, int statusCode) {
    Json payload = Json.emptyObject;
    payload["success"] = false;
    payload["message"] = message;
    payload["statusCode"] = statusCode;
    res.writeJsonBody(payload, statusCode);
  }
}
