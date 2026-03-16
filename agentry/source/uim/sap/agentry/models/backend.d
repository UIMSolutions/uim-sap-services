/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.agentry.models.backend;
import uim.sap.agentry;

mixin(ShowModule!());

@safe:
class AGTBackendSystem : SAPTenantObject {
  mixin(SAPObjectTemplate!AGTBackendSystem);

  UUID backendId;
  string systemType;
  string endpoint;
  string authMode;
  bool enabled = true;
  SysTime updatedAt;

  override Json toJson() {
    return supet.toJson
      .set("backend_id", backendId)
      .set("system_type", systemType)
      .set("endpoint", endpoint)
      .set("auth_mode", authMode)
      .set("enabled", enabled);
  }

  static AGTBackendSystem opCall(string tenantId, Json request) {
    AGTBackendSystem backend = new AGTBackendSystem(request);
    backend.tenantId = UUID(tenantId);
    backend.backendId = randomUUID().toString();
    backend.systemType = "s4hana";
    backend.authMode = "oauth2";
    backend.updatedAt = Clock.currTime();

    if ("backend_id" in request && request["backend_id"].isString) {
      backend.backendId = request["backend_id"].get!string;
    }
    if ("system_type" in request && request["system_type"].isString) {
      backend.systemType = toLower(request["system_type"].get!string);
    }
    if ("endpoint" in request && request["endpoint"].isString) {
      backend.endpoint = request["endpoint"].get!string;
    }
    if ("auth_mode" in request && request["auth_mode"].isString) {
      backend.authMode = toLower(request["auth_mode"].get!string);
    }
    if ("enabled" in request && request["enabled"].isBoolean) {
      backend.enabled = request["enabled"].get!bool;
    }

    return backend;
  }
}
