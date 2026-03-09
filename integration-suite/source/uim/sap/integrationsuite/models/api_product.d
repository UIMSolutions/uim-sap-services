/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.integrationsuite.models.api_product;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

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

  Json toJson() const {
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
  p.tenantId = tenantId;
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
