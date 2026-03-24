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

  void run() {
    auto settings = new HTTPServerSettings;
    settings.port = _service.config.port;
    settings.bindAddresses = [_service.config.host];
    listenHTTP(settings, &handleRequest);
    runApplication();
  }

  string basePath;
  string path;

  void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
    foreach (key, value; _service.config.customHeaders)
      res.headers[key] = value;

    basePath = _service.config.basePath;
    path = req.path;
  }

  Json toJson() {
    return Json.emptyObject;
  }
}
