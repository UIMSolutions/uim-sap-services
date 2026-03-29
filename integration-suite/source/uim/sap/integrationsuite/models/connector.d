/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.integrationsuite.models.connector;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

/**
  * Represents a connector configuration for external systems.
  * Connectors define how to connect and authenticate to external systems like Salesforce, Slack, etc.
  * They include details about the connection type, authentication scheme, and configuration parameters.
  *
  * Fields:
  * - tenantId: The ID of the tenant that owns this connector.
  * - connectorId: Unique identifier for the connector.
  * - name: Human-readable name of the connector.
  * - description: Optional description of the connector.
  * - connectorType: Type of the connector (e.g. prebuilt, custom).
  * - provider: The external system this connector connects to (e.g. Salesforce, Slack).
  * - authScheme: Authentication scheme used (e.g. oauth2, basic, apikey, none).
  * - status: Current status of the connector (e.g. active, inactive, error).
  * - baseUrl: Base URL for the external system's API.
  * - configuration: JSON object containing connector-specific configuration parameters.
  * - callCount: Total number of calls made using this connector.
  * - createdAt: Timestamp when the connector was created.
  * - updatedAt: Timestamp when the connector was last updated.
  * The toJson method converts the connector instance into a JSON representation for API responses or storage.
  * The connectorFromJson function creates a new connector instance from a JSON request, generating a unique connectorId and setting the createdAt and updatedAt timestamps.
  *
  * Example usage:
  * Json request = ...; // JSON payload from API request
  * INTConnector connector = connectorFromJson("tenant123", request);
  * Json response = connector.toJson(); // Convert connector to JSON for API response
  * For more information on connectors and their management, refer to the SAP Integration Suite documentation.
  */
class INTConnector : SAPTenantEntity {
  mixin(SAPTenantEntityTemplate!INTConnector);

  UUID connectorId;
  string name;
  string description;
  string connectorType = "prebuilt"; // prebuilt | custom
  string provider; // e.g. Salesforce, Slack, AWS S3
  string authScheme = "oauth2"; // oauth2 | basic | apikey | none
  string status = "active"; // active | inactive | error
  string baseUrl;
  Json configuration;
  long callCount = 0;

  override Json toJson()  {
    return super.toJson()
      .set("connector_id", connectorId)
      .set("name", name)
      .set("description", description)
      .set("connector_type", connectorType)
      .set("provider", provider)
      .set("auth_scheme", authScheme)
      .set("status", status)
      .set("base_url", baseUrl)
      .set("configuration", configuration)
      .set("call_count", callCount);
  }
}

INTConnector connectorFromJson(UUID tenantId, Json request) {
  INTConnector c;
  c.tenantId = tenantId;
  c.connectorId = randomUUID();

  if ("name" in request && request["name"].isString)
    c.name = request["name"].getString;
  if ("description" in request && request["description"].isString)
    c.description = request["description"].getString;
  if ("connector_type" in request && request["connector_type"].isString)
    c.connectorType = request["connector_type"].getString;
  if ("provider" in request && request["provider"].isString)
    c.provider = request["provider"].getString;
  if ("auth_scheme" in request && request["auth_scheme"].isString)
    c.authScheme = request["auth_scheme"].getString;
  if ("base_url" in request && request["base_url"].isString)
    c.baseUrl = request["base_url"].getString;
  if ("configuration" in request)
    c.configuration = request["configuration"];
  else
    c.configuration = Json.emptyObject;

  c.createdAt = Clock.currTime().toINTOExtString();
  c.updatedAt = c.createdAt;
  return c;
}
