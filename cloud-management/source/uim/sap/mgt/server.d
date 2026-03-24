module uim.sap.mgt.server;

import uim.sap.mgt;

mixin(ShowModule!());

@safe:

/**
  * This file defines the MGTServer class, which is responsible for handling incoming HTTP requests and routing them to the appropriate methods in the MGTService class.
  * It uses the vibe.d HTTP server to listen for requests and provides endpoints for health checks, readiness checks, and various operations related to environments, subaccounts, organizations, spaces, applications, services, service instances, and destinations.
  * The server also handles authentication if required by the configuration and returns appropriate error responses for unauthorized access or other exceptions.
  *
  * Fields:
  * - MGTService _service: An instance of the MGTService class that contains the
  *   business logic for handling the various operations.
  *
  * Example usage:
  * MGTConfig config = MGTConfig(
  *     host: "0.0.0.0",
  *     port: 8088,
  *     basePath: "/api/mgt"
  * );
  */
class MGTServer : SAPServer {
  mixin(SAPServerTemplate!MGTServer);
  
  private MGTService _service;

  this(MGTService service) {
    _service = service;
  }

  override void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
    super.handleRequest(req, res);

    try {
      validateAuth(req, _service.config);

      if (subPath == "/v1/environments" && req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.environments(), 200);
        return;
      }
      if (subPath == "/v1/subaccounts" && req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.subaccounts(), 200);
        return;
      }
      if (subPath == "/v1/organizations" && req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.organizations(), 200);
        return;
      }
      if (subPath == "/v1/spaces" && req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.spaces(), 200);
        return;
      }
      if (subPath == "/v1/applications" && req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.applications(), 200);
        return;
      }
      if (subPath.startsWith("/v1/applications/") && req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.application(lastSegment(subPath)), 200);
        return;
      }
      if (subPath == "/v1/services" && req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.services(), 200);
        return;
      }
      if (subPath == "/v1/service_instances" && req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.serviceInstances(), 200);
        return;
      }
      if (subPath == "/v1/destinations" && req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.destinations(), 200);
        return;
      }
      if (subPath.startsWith("/v1/destinations/") && req.method == HTTPMethod.GET) {
        res.writeJsonBody(_service.destination(lastSegment(subPath)), 200);
        return;
      }

      respondError(res, "Not found", 404);
    } catch (MGTAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (MGTUpstreamException e) {
      respondError(res, e.msg, 502);
    } catch (MGTException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
    }
  }
}
