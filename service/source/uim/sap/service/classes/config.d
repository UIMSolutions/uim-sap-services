/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.service.classes.config;

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

    if (initData.hasKey("host") && initData.isString("host")) {
      host(initData.getString("host"));
    }

    if (initData.hasKey("port") && initData.isNumber("port")) {
      port(cast(ushort)initData.getNumber("port"));
    }

    if (initData.hasKey("basePath") && initData.isString("basePath")) {
      basePath(initData.getString("basePath"));
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

  protected string _host;
  string host() const {
    return _host;
  }

  void host(string host_) {
    _host = host_;
  }

  protected ushort _port;
  ushort port() const {
    return _port;
  }

  void port(ushort port_) {
    _port = port_;
  }

  protected string _basePath;
  string basePath() const {
    return _basePath;
  }

  void basePath(string path) {
    _basePath = path;
  }

  void validate() {
    if (serviceName.length == 0) {
      throw new Exception("Service name cannot be empty");
    }

    if (serviceVersion.length == 0) {
      throw new Exception("Service version cannot be empty");
    }

    if (host.length == 0) {
      throw new Exception("Host cannot be empty");
    }

    if (port == 0) {
      throw new Exception("Port must be greater than zero");
    }

    if (basePath.length == 0) {
      throw new Exception("Base path cannot be empty");
    }

    if (!basePath.startsWith("/")) {
      throw new Exception("Base path must start with '/'");
    }
  }
}
