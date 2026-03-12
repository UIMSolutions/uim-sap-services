/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.smg.config;

import uim.sap.smg;

mixin(ShowModule!());

@safe:

class SMGConfig : SAPConfig {
  mixin(SAPConfigTemplate!SMGConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    /// Netwerk
    host(initData.getString("host", "0.0.0.0"));
    port(cast(ushort)initData.getInteger("port", 8094));
    basePath(initData.getString("basePath", "/api/sitemanager"));

    /// Service metadata
    serviceName(initData.getString("serviceName", "uim-smg"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    return true;
  }

  bool requireAuthToken = false;
  string authToken;

  string[string] customHeaders;

  protected bool _requireAuthToken = false;
  bool requireAuthToken() const {
    return _requireAuthToken;
  }

  void requireAuthToken(bool value) {
    _requireAuthToken = value;
  }

  protected string _authToken;
  string authToken() const {
    return _authToken;
  }

  void authToken(string value) {
    _authToken = value;
  }

  protected string[string] _customHeaders;
  string[string] customHeaders() const {
    return _customHeaders;
  }

  void customHeaders(string[string] value) {
    _customHeaders = value;
  }

  string customHeader(string key) const {
    return _customHeaders[key];
  }

  void customHeader(string key, string value) {
    _customHeaders[key] = value;
  }

  override void validate() const {
    super.validate();

    if (requireAuthToken && authToken.length == 0)
      throw new SMGConfigurationException("Auth token required when token auth is enabled");
  }
}
