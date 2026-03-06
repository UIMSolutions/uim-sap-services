/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.smg.config;

import uim.sap.smg;

mixin(ShowModule!());

@safe:

struct SMGConfig : SAPConfig {
  mixin(SAPConfigTemplate!SMGConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    host = initData.hasKey("host") ? initData["host"] : "0.0.0.0";
    port = initData.hasKey("port") ? initData["port"].to!ushort : 8094;
    basePath = initData.hasKey("basePath") ? initData["basePath"] : "/api/sitemanager";

    serviceName = initData.hasKey("serviceName") ? initData["serviceName"] : "uim-sap-smg";
    serviceVersion = initData.hasKey("serviceVersion") ? initData["serviceVersion"] : "1.0.0";

    bool requireAuthToken = false;
    string authToken;

    string[string] customHeaders;
  }

  protected string _host;
  string host() const { return _host; }
  void host(string value) { _host = value; }

  protected ushort _port;
  ushort port() const { return _port; }
  void port(ushort value) { _port = value; }

  protected string _basePath;
  string basePath() const { return _basePath; }
  void basePath(string value) { _basePath = value; }

  protected string _serviceName = "uim-sap-smg";
  string serviceName() const { return _serviceName; }
  void serviceName(string value) { _serviceName = value; }

  protected string _serviceVersion = "1.0.0";
  string serviceVersion() const { return _serviceVersion; }
  void serviceVersion(string value) { _serviceVersion = value; }

  protected bool _requireAuthToken = false;
  bool requireAuthToken() const { return _requireAuthToken; }
  void requireAuthToken(bool value) { _requireAuthToken = value; }

  protected string _authToken;
  string authToken() const { return _authToken; }
  void authToken(string value) { _authToken = value; }

  protected string[string] _customHeaders;
  string[string] customHeaders() const { return _customHeaders; }
  void customHeaders(string[string] value) { _customHeaders = value; }

  string customHeader(string key) const { return _customHeaders[key]; }
  void customHeader(string key, string value) { _customHeaders[key] = value; }

  void validate() const {
    if (host.length == 0)
      throw new SMGConfigurationException("Host cannot be empty");
    if (port == 0)
      throw new SMGConfigurationException("Port must be greater than zero");
    if (basePath.length == 0 || !basePath.startsWith("/"))
      throw new SMGConfigurationException("Base path must start with '/'");
    if (serviceName.length == 0)
      throw new SMGConfigurationException("Service name cannot be empty");
    if (requireAuthToken && authToken.length == 0)
      throw new SMGConfigurationException("Auth token required when token auth is enabled");
  }
}
