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
			CONConfig cfg = cast(CONConfig)_config;
			
    return super.health()
    .set("connector_location_id", cfg.connectorLocationId)
    .set("destinations", cast(long)_store.countDestinations());
  }

  Json supportedProtocols() {
    Json protocols = CON_SUPPORTED_PROTOCOLS.toJson;

    return Json.emptyObject
    .set("protocols", protocols)
    .set("supports_hybrid_connectivity", true)
    .set("supports_identity_propagation", true)
    .set("supports_multitenancy", true)
    .set("firewall_changes_required", false);
  }

  Json upsertDestination(UUID tenantId, string destinationName, Json request) {
    validateTenant(tenantId);
    validateName(destinationName, "Destination name");

    auto destination = destinationFromJson(tenantId, destinationName, request);
    validateDestination(destination);
    destination.updatedAt = Clock.currTime();

    auto saved = _store.upsertDestination(destination);

    return Json.emptyObject
    .set("success", true)
    .set("destination", saved.toJson())
    .set("deployment_benefit", "hybrid tunnel without firewall reconfiguration");
  }

  Json listDestinations(UUID tenantId) {
    validateTenant(tenantId);

    Json resources = _store.listDestinations(tenantId)
      .map!(dest => dest.toJson()).array.toJson;

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long)_store.countDestinations(tenantId));
  }

  Json getDestination(UUID tenantId, string destinationName) {
    validateTenant(tenantId);
    validateName(destinationName, "Destination name");

    auto destination = _store.getDestination(tenantId, destinationName);
    if (destination.name.length == 0) {
      throw new CONNotFoundException("Destination", tenantId ~ "/" ~ destinationName);
    }

    return Json.emptyObject
    .set("destination", destination.toJson());
  }

  Json deleteDestination(UUID tenantId, string destinationName) {
    validateTenant(tenantId);
    validateName(destinationName, "Destination name");

    if (!_store.deleteDestination(tenantId, destinationName)) {
      throw new CONNotFoundException("Destination", tenantId ~ "/" ~ destinationName);
    }

    return Json.emptyObject
      .set("success", true)
      .set("tenant_id", tenantId)
      .set("destination_name", destinationName)
      .set("message", "Destination deleted");
  }

  Json listCloudDatabases(UUID tenantId) {
    validateTenant(tenantId);

    Json resources = _store.listCloudDatabases(tenantId)
      .map!(database => database.toJson()).array.toJson;

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length)
      .set("access_mode", "jdbc-odbc-local-like");

  }

  Json listTenants() {
    Json resources = Json.emptyArray;

    foreach (tenantId; _store.listTenantIds()) {
      CONTenantSummary summary;
      summary.tenantId = UUID(tenantId);
      summary.destinations = _store.countDestinations(tenantId);
      resources ~= summary.toJson();
    }

    return Json.emptyObject
      .set("resources", resources)
      .set("total_results", cast(long)resources.length)
      .set("multitenant_mode", "shared-compute");
  }

  Json connect(UUID tenantId, string destinationName, Json request, string cloudIdentityHeader) {
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

    return Json.emptyObject
      .set("success", true)
      .set("tenant_id", tenantId)
      .set("destination_name", destinationName)
      .set("destination", destination.toJson())
      .set("route", route)
      .set("identity", identity)
      .set("cloud_database_access", destination.cloudDatabase)
      .set("message", "Connectivity route prepared");
  }

  private void validateTenant(UUID tenantId) {
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
