module uim.sap.mdi.models.replicationclient;

import uim.sap.mdi;

mixin(ShowModule!());

@safe:

/**
 * Model representing a replication client in the Master Data Integration service.
 *
  * This model is used to store and manage information about replication clients, including their tenant ID, client ID, name, system type, and the last update timestamp.
  *
  * Example usage:
  * ```
  * MDIReplicationClient client;
  * client.tenantId = "tenant123";
  * client.clientId = "client456";
  * client.name = "Client Name";
  * client.systemType = "sap";
  * client.updatedAt = Clock.currTime();
  * ```
  * 
  * Fields:
  * - `tenantId`: The ID of the tenant to which this replication client belongs.
  * - `clientId`: A unique identifier for the replication client.
  * - `name`: A human-readable name for the replication client.
  * - `systemType`: The type of system the replication client is associated with (e.g., "sap").
  * - `updatedAt`: A timestamp indicating when the replication client was last updated.
 */
struct MDIReplicationClient {
  UUID tenantId;
  string clientId;
  string name;
  string systemType;
  SysTime updatedAt;

  override Json toJson()  {
    Json info = super.toJson;
    payload["tenant_id"] = tenantId;
    payload["client_id"] = clientId;
    payload["name"] = name;
    payload["system_type"] = systemType;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}

MDIReplicationClient clientFromJson(string tenantId, Json request) {
  MDIReplicationClient client;
  client.tenantId = UUID(tenantId);
  client.clientId = createId();
  client.updatedAt = Clock.currTime();
  client.systemType = "sap";

  if ("client_id" in request && request["client_id"].isString)
    client.clientId = request["client_id"].get!string;
  if ("name" in request && request["name"].isString)
    client.name = request["name"].get!string;
  if ("system_type" in request && request["system_type"].isString)
    client.systemType = request["system_type"].get!string;
  return client;
}
