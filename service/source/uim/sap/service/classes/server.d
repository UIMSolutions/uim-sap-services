module uim.sap.service.classes.server;

import uim.sap.service;

mixin(ShowModule!());

@safe:

class SAPServer {
  this() {
    initialize();
  }

  this(Json initData) {
    if (initData.isArray) {
      initialize(initData.toArray);
    }
    if (initData.isObject) {
      initialize(initData.toMap);
    }
  }

  this(Json[] initData) {
    initialize(initData);
  }

  this(Json[string] initData) {
    initialize(initData);
  }

  bool initialize(Json[] initData) {
    // Initialization logic for the object
    return true;
  }

  bool initialize(Json[string] initData = null) {
    // Initialization logic for the store
    return true;
  }

  protected string _host;
  protected ushort _port;
  protected string _basePath;
  protected string _subPath;
  protected bool _requireAuthToken;
  protected string _authToken;
  protected string[string] _customHeaders;

  void run() {
    auto settings = new HTTPServerSettings;
    settings.port = _service.config.port;
    settings.bindAddresses = [_service.config.host];
    listenHTTP(settings, &handleRequest);
    runApplication();
  }

  void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
    foreach (key, value; _service.config.customHeaders)
      res.headers[key] = value;

    _basePath = _service.config.basePath;
    auto path = req.path;
    if (!path.startsWith(_basePath)) {
      respondError(res, "Not found", 404);
      return;
    }

    _subPath = path[_basePath.length .. $];
    if (_subPath.length == 0)
      _subPath = "/";

    if (_subPath == "/health" && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.health(), 200);
      return;
    }

    if (_subPath == "/ready" && req.method == HTTPMethod.GET) {
      res.writeJsonBody(_service.ready(), 200);
      return;
    }
  }

  Json toJson() {
    return Json.emptyObject;
  }
}
