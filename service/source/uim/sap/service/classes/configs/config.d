/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.service.classes.configs.config;

import core.sync.mutex : Mutex;
import uim.sap.service;

mixin(ShowModule!());

@safe:

/**
  * Base configuration class for SAP services.
  * Contains common configuration properties and initialization logic.
  * Specific services can extend this class to add their own configuration properties and validation.
  *
  * Example usage:
  * class MyServiceConfig : SAPConfig {
  *   string customProperty;
  *   override bool initialize(Json[string] initData = null) {
  *     if (!super.initialize(initData)) {
  *       return false;
  *     }
  *     customProperty = initData.getString("customProperty", "defaultValue");    
  *     return true;
  *   }
  * }
  */
class SAPConfig : ISAPConfig {  
  this() {
    initialize();
  }

  this(Json[string] initData) {
    initialize(initData);
  }

  bool initialize(Json[string] initData = null) {
    if (initData.hasKey("serviceName") && initData.isString("serviceName")) {
      serviceName(initData.getString("serviceName"));
    }

    if (initData.hasKey("serviceVersion") && initData.isString("serviceVersion")) {
      serviceVersion(initData.getString("serviceVersion"));
    }

    return true;
  }

  protected string _serviceName;
  string serviceName() const {
    return _serviceName;
  }

  void serviceName(string name) {
    _serviceName = name;
  }

  protected string _serviceVersion;
  string serviceVersion() const {
    return _serviceVersion;
  }

  void serviceVersion(string version_) {
    _serviceVersion = version_;
  }
}
