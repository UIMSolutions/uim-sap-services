/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.con.service;

import uim.sap.con;
@safe:

class CONService : SAPService {
  mixin(SAPServiceTemplate!CONService);

  private CONStore _store;

  this(CONConfig config) {
    super(config);

    _store = new CONStore;
  }

  override Json health() {
    Json healthInfo = super.health();
    healthInfo["connector_location_id"] = _config.connectorLocationId;
    healthInfo["destinations"] = cast(long)_store.countDestinations();
    return healthInfo;
  }

  Json supportedProtocols() {
    Json protocols = CON_SUPPORTED_PROTOCOLS.toJson;

    Json payload = Json.emptyObject;
    payload["protocols"] = protocols;
    payload["supports_hybrid_connectivity"] = true;
    payload["supports_identity_propagation"] = true;
    payload["supports_multitenancy"] = true;
    payload["firewall_changes_required"] = false;
    return payload;
  }

  Json upsertDestination(string tenantId, string destinationName, Json request) {
    validateTenant(tenantId);
    validateName(destinationName, "Destination name");

    auto destination = destinationFromJson(tenantId, destinationName, request);
    validateDestination(destination);
    destination.updatedAt = Clock.currTime();

    auto saved = _store.upsertDestination(destination);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["destination"] = saved.toJson();
    payload["deployment_benefit"] = "hybrid tunnel without firewall reconfiguration";
    return payload;
  }

  Json listDestinations(string tenantId) {
    validateTenant(tenantId);

    Json resources = _store.listDestinations(tenantId).map!(dest => destination.toJson()).array.toJson; 

    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)_store.countDestinations(tenantId);
    return payload;
  }

  Json getDestination(string tenantId, string destinationName) {
    validateTenant(tenantId);
    validateName(destinationName, "Destination name");

    auto destination = _store.getDestination(tenantId, destinationName);
    if (destination.name.length == 0) {
      throw new CONNotFoundException("Destination", tenantId ~ "/" ~ destinationName);
    }

    Json payload = Json.emptyObject;
    payload["destination"] = destination.toJson();
    return payload;
  }

  Json deleteDestination(string tenantId, string destinationName) {
    validateTenant(tenantId);
    validateName(destinationName, "Destination name");

    if (!_store.deleteDestination(tenantId, destinationName)) {
      throw new CONNotFoundException("Destination", tenantId ~ "/" ~ destinationName);
    }

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["tenant_id"] = tenantId;
    payload["destination_name"] = destinationName;
    payload["message"] = "Destination deleted";
    return payload;
  }

  Json listCloudDatabases(string tenantId) {
    validateTenant(tenantId);

    Json resources = _store.listCloudDatabases(tenantId).map!(database => database.toJson()).array.toJson;

    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)resources.length;
    payload["access_mode"] = "jdbc-odbc-local-like";
    return payload;
  }

  Json listTenants() {
    Json payload = Json.emptyObject;
    Json resources = Json.emptyArray;

    foreach (tenantId; _store.listTenantIds()) {
      CONTenantSummary summary;
      summary.tenantId = tenantId;
      summary.destinations = _store.countDestinations(tenantId);
      resources ~= summary.toJson();
    }

    payload["resources"] = resources;
    payload["total_results"] = cast(long)resources.length;
    payload["multitenant_mode"] = "shared-compute";
    return payload;
  }

  Json connect(string tenantId, string destinationName, Json request, string cloudIdentityHeader) {
    validateTenant(tenantId);
    validateName(destinationName, "Destination name");

    auto destination = _store.getDestination(tenantId, destinationName);
    if (destination.name.length == 0) {
      throw new CONNotFoundException("Destination", tenantId ~ "/" ~ destinationName);
    }

    bool forwardIdentity = true;
    if ("forward_identity" in request && request["forward_identity"].isBoolean) {
      forwardIdentity = request["forward_identity"].get!bool;
    }

    string userIdentity = cloudIdentityHeader;
    if (userIdentity.length == 0 && "user_identity" in request && request["user_identity"].isString) {
      userIdentity = request["user_identity"].get!string;
    }

    auto propagated = destination.identityPropagationEnabled && forwardIdentity && userIdentity.length > 0;

    Json identity = Json.emptyObject;
    identity["forwarded"] = propagated;
    identity["principal"] = propagated ? userIdentity : "";
    identity["mechanism"] = propagated ? "cloud-principal-propagation" : "none";

    Json route = Json.emptyObject;
    route["protocol"] = destination.protocol;
    route["target_host"] = destination.targetHost;
    route["target_port"] = cast(long)destination.targetPort;
    route["target_path"] = destination.targetPath;
    route["connector_location_id"] = _config.connectorLocationId;
    route["network_path"] = destination.onPremise ? "cloud-connector-tunnel" : "direct";
    route["firewall_changes_required"] = false;

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["tenant_id"] = tenantId;
    payload["destination_name"] = destinationName;
    payload["destination"] = destination.toJson();
    payload["route"] = route;
    payload["identity"] = identity;
    payload["cloud_database_access"] = destination.cloudDatabase;
    payload["message"] = "Connectivity route prepared";
    return payload;
  }

  private void validateTenant(string tenantId) {
    validateName(tenantId, "Tenant ID");
  }

  private void validateName(string value, string fieldName) {
    if (value.length == 0) {
      throw new CONValidationException(fieldName ~ " cannot be empty");
    }
  }

  private void validateDestination(CONDestination destination) {
    if (destination.protocol.length == 0) {
      throw new CONValidationException("protocol is required");
    }
    if (!isSupportedProtocol(destination.protocol)) {
      throw new CONValidationException("Unsupported protocol: " ~ destination.protocol);
    }
    if (destination.targetHost.length == 0) {
      throw new CONValidationException("target_host is required");
    }
    if (destination.targetPort == 0) {
      throw new CONValidationException("target_port is required");
    }
  }
}
