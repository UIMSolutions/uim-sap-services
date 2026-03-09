module uim.sap.service.classes.service;

import core.sync.mutex : Mutex;
import uim.sap.service;

mixin(ShowModule!());

@safe:

class SAPService : ISAPService {
  this() {
    this.initialize();
  }

  this(Json[string] initData = null) {
    this.initialize(initData);
  }

  this(ISAPConfig config) {
    config.validate();
    _config = config;
    this.initialize();
  }

  bool initialize(Json[string] initData = null) {
    // Initialization logic for the store

    return true;
  }

  protected ISAPConfig _config;
  ISAPConfig config() {
    return _config;
  }

  void config(ISAPConfig cfg) {
    _config = cfg;
  }

  Json health() {
    Json healthInfo = Json.emptyObject;
    healthInfo["ok"] = true;
    healthInfo["status"] = "UP";
    healthInfo["service"] = _config.serviceName;
    healthInfo["version"] = _config.serviceVersion;
    return healthInfo;
  }

  Json ready() {
    Json readyInfo = Json.emptyObject;
    readyInfo["ready"] = true;
    readyInfo["status"] = "READY";
    readyInfo["timestamp"] = Clock.currTime().toISOExtString();

    return readyInfo;
  }
}
