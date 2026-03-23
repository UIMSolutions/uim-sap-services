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

  string name;
  string protocol;
  string targetHost;
  ushort targetPort;
  string targetPath;

  bool onPremise = true;
  bool cloudDatabase = false;
  bool identityPropagationEnabled = true;

  Json metadata;

  override Json toJson()  {
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
}

CONDestination destinationFromJson(UUID tenantId, string name, Json request) {
  CONDestination destination;
  destination.tenantId = tenantId;
  destination.name = name;
  destination.createdAt = Clock.currTime();
  destination.updatedAt = destination.createdAt;
  destination.targetPath = "/";

  if ("protocol" in request && request["protocol"].isString) {
    destination.protocol = normalizeProtocol(request["protocol"].get!string);
  }
  if ("target_host" in request && request["target_host"].isString) {
    destination.targetHost = request["target_host"].get!string;
  }
  if ("target_port" in request && request["target_port"].isInteger) {
    auto value = request["target_port"].get!long;
    if (value > 0 && value <= ushort.max) {
      destination.targetPort = cast(ushort)value;
    }
  }
  if ("target_path" in request && request["target_path"].isString) {
    destination.targetPath = request["target_path"].get!string;
  }
  if ("on_premise" in request && request["on_premise"].isBoolean) {
    destination.onPremise = request["on_premise"].get!bool;
  }
  if ("cloud_database" in request && request["cloud_database"].isBoolean) {
    destination.cloudDatabase = request["cloud_database"].get!bool;
  }
  if ("identity_propagation_enabled" in request && request["identity_propagation_enabled"]
    .isBoolean) {
    destination.identityPropagationEnabled = request["identity_propagation_enabled"].get!bool;
  }
  if ("metadata" in request && request["metadata"].isObject) {
    destination.metadata = request["metadata"];
  } else {
    destination.metadata = Json.emptyObject;
  }

  if (destination.protocol == "jdbc" || destination.protocol == "odbc") {
    destination.cloudDatabase = true;
  }

  if (destination.targetPort == 0 && destination.protocol.length > 0) {
    destination.targetPort = defaultPortForProtocol(destination.protocol);
  }

  return destination;
}
