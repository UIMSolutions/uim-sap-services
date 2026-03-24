module uim.sap.dqm.server;

import uim.sap.dqm;

mixin(ShowModule!());

@safe:


class DQMServer : SAPServer {
  mixin(SAPServerTemplate!DQMServer);

  private DQMService _service;

  this(DQMService service) {
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

      if (segments.length == 3 && segments[0] == "v1" && segments[1] == "address" && segments[2] == "cleanse" && req
        .method == HTTPMethod.POST) {
        res.writeJsonBody(_service.cleanseAddress(req.json), 200);
        return;
      }

      if (segments.length == 2 && segments[0] == "v1" && segments[1] == "geocode" && req.method == HTTPMethod
        .POST) {
        res.writeJsonBody(_service.geocode(req.json), 200);
        return;
      }

      if (segments.length == 2 && segments[0] == "v1" && segments[1] == "reverse-geocode" && req.method == HTTPMethod
        .POST) {
        res.writeJsonBody(_service.reverseGeocode(req.json), 200);
        return;
      }

      if (segments.length == 3 && segments[0] == "v1" && segments[1] == "address" && segments[2] == "suggest" && req
        .method == HTTPMethod.POST) {
        res.writeJsonBody(_service.suggestAddresses(req.json), 200);
        return;
      }

      respondError(res, "Not found", 404);
    } catch (DQMAuthorizationException e) {
      respondError(res, e.msg, 401);
    } catch (DQMNotFoundException e) {
      respondError(res, e.msg, 404);
    } catch (DQMValidationException e) {
      respondError(res, e.msg, 422);
    } catch (DQMException e) {
      respondError(res, e.msg, 500);
    } catch (Exception e) {
      respondError(res, e.msg, 500);
    }
  }
}
