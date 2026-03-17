/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.alertnotification.config;

import uim.sap.alertnotification;

mixin(ShowModule!());

@safe:

class AlertNotificationConfig : SAPConfig {
  mixin(SAPConfigTemplate!AlertNotificationConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    port(cast(ushort)initData.getInteger("port", 8097));
    host(initData.getString("host", "0.0.0.0"));
    basePath(initData.getString("basePath", "/api/alert-notification"));
    serviceName(initData.getString("serviceName", "uim-alert-notification"));
    serviceVersion(initData.getString("serviceVersion", "1.0.0"));

    requireAuthToken(initData.getBoolean("requireAuthToken", false));
    if (requireAuthToken) {
      authToken(initData.getString("authToken", ""));
    }

    return true;
  }
}
