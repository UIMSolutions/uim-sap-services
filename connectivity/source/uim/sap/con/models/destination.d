/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.con.models.destination;

import uim.sap.con;

mixin(ShowModule!());

@safe:

class CONDestination : SAPTenantObject {
  mixin(SAPObjectTemplate!CONDestination);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("protocol" in initData && initData["protocol"].isString) {
      protocol = normalizeProtocol(initData["protocol"].get!string);
    }
    if ("target_host" in initData && initData["target_host"].isString) {
      targetHost = initData["target_host"].get!string;
    }
    if ("target_port" in initData && initData["target_port"].isInteger) {
      auto value = initData["target_port"].get!long;
      if (value > 0 && value <= ushort.max) {
        targetPort = cast(ushort)value;
      }
    }
    if ("target_path" in initData && initData["target_path"].isString) {
      targetPath = initData["target_path"].get!string;
    }
    if ("on_premise" in initData && initData["on_premise"].isBoolean) {
      onPremise = initData["on_premise"].get!bool;
    }
    if ("cloud_database" in initData && initData["cloud_database"].isBoolean) {
      cloudDatabase = initData["cloud_database"].get!bool;
    }
    if ("identity_propagation_enabled" in initData && initData["identity_propagation_enabled"]
      .isBoolean) {
      identityPropagationEnabled = initData["identity_propagation_enabled"].get!bool;
    }
    if ("metadata" in initData && initData["metadata"].isObject) {
      metadata = initData["metadata"];
    } else {
      metadata = Json.emptyObject;
    }

    if (protocol == "jdbc" || protocol == "odbc") {
      cloudDatabase = true;
    }

    if (targetPort == 0 && protocol.length > 0) {
      targetPort = defaultPortForProtocol(protocol);
    }

    return true;
  }

  string name;
  string protocol;
  string targetHost;
  ushort targetPort;
  string targetPath;
  bool onPremise = true;
  bool cloudDatabase = false;
  bool identityPropagationEnabled = true;
  Json metadata;

  override Json toJson() {
    return super.toJson
      .set("name", name)
      .set("protocol", protocol)
      .set("target_host", targetHost)
      .set("target_port", cast(long)targetPort)
      .set("target_path", targetPath)
      .set("on_premise", onPremise)
      .set("cloud_database", cloudDatabase)
      .set("identity_propagation_enabled", identityPropagationEnabled)
      .set("metadata", metadata);
  }

  static CONDestination opCall(UUID tenantId, string name, Json request) {
    CONDestination destination = new CONDestination(request);
    destination.tenantId = tenantId;
    destination.name = name;
    destination.createdAt = Clock.currTime();
    destination.updatedAt = destination.createdAt;
    destination.targetPath = "/";

    return destination;
  }
}
