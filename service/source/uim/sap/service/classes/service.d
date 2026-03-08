module uim.sap.service.classes.service;

import core.sync.mutex : Mutex;
import uim.sap.service;

mixin(ShowModule!());

@safe:

class SAPService : ISAPService {
  this() {
    initialize();
  }

  this(Json[string] initData = null) {
    initialize(initData);
  }

  bool initialize(Json[string] initData = null) {
    // Initialization logic for the store

    return true;
  }

  protected ISAPConfig _config;
  ISAPConfig config() const {
    return _config;
  }

  void config(ISAPConfig cfg) {
    _config = cfg;
  }

  Json health() {
    Json healthInfo = Json.emptyObject;
    healthInfo["ok"] = true;
    healthInfo["serviceName"] = _config.serviceName;
    healthInfo["serviceVersion"] = _config.serviceVersion;
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
