/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.integrationsuite.models.api_product;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

/**
  * Represents an API Product in the SAP Integration Suite.
  * An API Product is a collection of API Proxies that are offered as a package to developers.
  * It includes metadata such as name, description, version, status, and associated policies.
  *
  * Fields:
  * - tenantId: The ID of the tenant that owns this API Product.
  * - productId: Unique identifier for the API Product.
  * - name: Name of the API Product.
  * - description: A brief description of the API Product.
  * - version: Version of the API Product, following semantic versioning.
  * - status: Current lifecycle status of the API Product (e.g., draft, published, deprecated).
  * - proxyIds: List of API Proxy IDs that are included in this API Product.
  * - subscriberCount: Number of developers subscribed to this API Product.
  * - rateLimitPolicy: The rate limiting policy applied to this API Product (e.g., 1000 requests per minute).
  * - createdAt: Timestamp of when the API Product was created.
  * - updatedAt: Timestamp of the last update to the API Product.
  *
  * Methods:
  * - toJson(): Serializes the API Product to a JSON object for API responses.
  * - apiProductFromJson(): Factory function to create an API Product instance from a JSON request.
  *
  * Example usage:
  *   // Creating an API Product from a JSON request
  *   Json request = ...; // JSON payload from API request
  *   INTApiProduct product = apiProductFromJson("tenant123", request);
  *   // Serializing an API Product to JSON for response
  *   Json response = product.toJson();
  */
struct INTApiProduct {
  string tenantId;
  string productId;
  string name;
  string description;
  string version_ = "1.0.0";
  string status = "published"; // draft | published | deprecated
  string[] proxyIds;
  long subscriberCount = 0;
  string rateLimitPolicy;
  string createdAt;
  string updatedAt;

  override Json toJson()  {
    Json j = Json.emptyObject;
    j["tenant_id"] = tenantId;
    j["product_id"] = productId;
    j["name"] = name;
    j["description"] = description;
    j["version"] = version_;
    j["status"] = status;

    Json ids = Json.emptyArray;
    foreach (id; proxyIds)
      ids ~= Json(id);
    j["proxy_ids"] = ids;

    j["subscriber_count"] = subscriberCount;
    j["rate_limit_policy"] = rateLimitPolicy;
    j["created_at"] = createdAt;
    j["updated_at"] = updatedAt;
    return j;
  }
}

INTApiProduct apiProductFromJson(string tenantId, Json request) {
  INTApiProduct p;
  p.tenantId = UUID(tenantId);
  p.productId = randomUUID().toString();

  if ("name" in request && request["name"].isString)
    p.name = request["name"].get!string;
  if ("description" in request && request["description"].isString)
    p.description = request["description"].get!string;
  if ("version" in request && request["version"].isString)
    p.version_ = request["version"].get!string;
  if ("rate_limit_policy" in request && request["rate_limit_policy"].isString)
    p.rateLimitPolicy = request["rate_limit_policy"].get!string;
  if ("proxy_ids" in request && request["proxy_ids"].isArray) {
    foreach (item; request["proxy_ids"]) {
      if (item.isString)
        p.proxyIds ~= item.get!string;
    }
  }

  p.createdAt = Clock.currTime().toINTOExtString();
  p.updatedAt = p.createdAt;
  return p;
}
