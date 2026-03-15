/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.integrationsuite.models.api_proxy;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

/**
  * Represents an API Proxy in the SAP Integration Suite.
  *
  * An API Proxy is a virtual API endpoint that acts as an intermediary between clients and backend services.
  * It allows you to apply policies, manage traffic, and secure access to your APIs without changing the backend services.
  * Key properties include:
  * - `tenantId`: The ID of the tenant that owns this API Proxy.
  * - `proxyId`: A unique identifier for the API Proxy.
  * - `name`: A human-readable name for the API Proxy.
  * - `description`: A detailed description of the API Proxy's purpose and functionality.
  * - `basePath`: The base path under which the API Proxy is exposed (e.g., `/myapi`).
  * - `targetUrl`: The URL of the backend service that the API Proxy forwards requests to.
  * - `version_`: The version of the API Proxy, following semantic versioning (e.g., `1.0.0`).
  * `status`: The current status of the API Proxy (e.g., `active`, `deprecated`, `revoked`).
  * `authScheme`: The authentication scheme used by the API Proxy (e.g., `none`, `apikey`, `oauth2`, `basic`).
  * `callCount`: The total number of calls made to this API Proxy.
  * `errorCount`: The total number of errors encountered when calling this API Proxy.
  * `policies`: A list of policy IDs that are applied to this API Proxy.
  * `createdAt`: The timestamp when the API Proxy was created.
  * `updatedAt`: The timestamp when the API Proxy was last updated.
  *
  * The `toJson` method converts the API Proxy instance into a JSON representation, which can be used for API responses or storage.
  * The `apiProxyFromJson` function creates a new API Proxy instance from a JSON request, generating a unique `proxyId` and setting the `createdAt` and `updatedAt` timestamps.
  *
  * Example usage:
  * Json request = ...; // JSON payload from API request
  * INTApiProxy proxy = apiProxyFromJson("tenant123", request);
  * Json response = proxy.toJson(); // Convert API Proxy to JSON for API response
  * For more information on API Proxies and their management, refer to the SAP Integration Suite documentation.
  */
struct INTApiProxy {
  UUID tenantId;
  UUID proxyId;
  string name;
  string description;
  string basePath;
  string targetUrl;
  string version_ = "1.0.0";
  string status = "active"; // active | deprecated | revoked
  string authScheme = "none"; // none | apikey | oauth2 | basic
  long callCount = 0;
  long errorCount = 0;
  string[] policies;
  string createdAt;
  string updatedAt;

  override Json toJson()  {
    Json j = Json.emptyObject;
    j["tenant_id"] = tenantId;
    j["proxy_id"] = proxyId;
    j["name"] = name;
    j["description"] = description;
    j["base_path"] = basePath;
    j["target_url"] = targetUrl;
    j["version"] = version_;
    j["status"] = status;
    j["auth_scheme"] = authScheme;
    j["call_count"] = callCount;
    j["error_count"] = errorCount;

    Json pols = Json.emptyArray;
    foreach (p; policies)
      pols ~= Json(p);
    j["policies"] = pols;

    j["created_at"] = createdAt;
    j["updated_at"] = updatedAt;
    return j;
  }
}

INTApiProxy apiProxyFromJson(string tenantId, Json request) {
  INTApiProxy p;
  p.tenantId = tenantId;
  p.proxyId = randomUUID().toString();

  if ("name" in request && request["name"].isString)
    p.name = request["name"].get!string;
  if ("description" in request && request["description"].isString)
    p.description = request["description"].get!string;
  if ("base_path" in request && request["base_path"].isString)
    p.basePath = request["base_path"].get!string;
  if ("target_url" in request && request["target_url"].isString)
    p.targetUrl = request["target_url"].get!string;
  if ("version" in request && request["version"].isString)
    p.version_ = request["version"].get!string;
  if ("auth_scheme" in request && request["auth_scheme"].isString)
    p.authScheme = request["auth_scheme"].get!string;

  p.createdAt = Clock.currTime().toINTOExtString();
  p.updatedAt = p.createdAt;
  return p;
}
