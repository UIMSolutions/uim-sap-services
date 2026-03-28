/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.agentry.models.backend;
import uim.sap.agentry;

mixin(ShowModule!());

@safe:

/**
 * Represents a backend system configuration for an Agentry mobile application.
 * Contains details about the backend system such as its type, endpoint, and authentication mode.
 *
  * This class is used to manage and store backend system configurations associated with mobile applications in the Agentry platform.
  *
  * Example usage:
  * ```
  * Json requestData = Json.emptyObject
  *   .set("backend_id", "123e4567-e89b-123e-4567-1234567890ab")
  *   .set("system_type", "s4hana")
  *   .set("endpoint", "https://mybackend.example.com")
  *   .set("auth_mode", "oauth2")
  *   .set("enabled", true);
  * AGTBackendSystem backend = AGTBackendSystem("tenant-id-123", requestData);
  * ```
 */
class AGTBackendSystem : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!AGTBackendSystem);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("backend_id" in initData && initData["backend_id"].isString) {
      backendId = toUUID(initData["backend_id"].get!string);
    }
    if ("system_type" in initData && initData["system_type"].isString) {
      systemType = toLower(initData["system_type"].get!string);
    }
    if ("endpoint" in initData && initData["endpoint"].isString) {
      endpoint = initData["endpoint"].getString;
    }
    if ("auth_mode" in initData && initData["auth_mode"].isString) {
      authMode = toLower(initData["auth_mode"].get!string);
    }
    if ("enabled" in initData && initData["enabled"].isBoolean) {
      enabled = initData["enabled"].get!bool;
    }

    return true;
  }

  UUID backendId;
  string systemType;
  string endpoint;
  string authMode;
  bool enabled = true;
  SysTime updatedAt;

  override Json toJson() {
    return super.toJson()
      .set("backend_id", backendId)
      .set("system_type", systemType)
      .set("endpoint", endpoint)
      .set("auth_mode", authMode)
      .set("enabled", enabled);
  }

  static AGTBackendSystem opCall(UUID tenantId, Json request) {
    AGTBackendSystem backend = new AGTBackendSystem(request);
    backend.tenantId = tenantId;
    backend.backendId = randomUUID();
    backend.systemType = "s4hana";
    backend.authMode = "oauth2";
    backend.updatedAt = Clock.currTime();

    return backend;
  }
}
