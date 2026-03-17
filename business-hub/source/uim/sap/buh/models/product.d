/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.buh.models.product;

import uim.sap.buh;

mixin(ShowModule!());

@safe:
class BUHProduct : SAPObject {
  mixin(SAPObjectTemplate!BUHProduct);

  UUID id;
  string name;
  string description;
  string[] apiIds;

  override Json toJson()  {
    Json apiIdsJson = apiIds.map!(api => Json(apiId)).array.toJson;

    return super.toJson
      .set("id", id)
      .set("name", name)
      .set("description", description)
      .set("api_ids", apiIdsJson);
  }

  static BUHProduct opCall(Json payload) {
    BUHProduct product = new BUHProduct;
    product.id = randomUUID().toString();
    product.createdAt = Clock.currTime();

    if ("name" in payload && payload["name"].isString) {
      product.name = payload["name"].get!string;
    }
    if ("description" in payload && payload["description"].isString) {
      product.description = payload["description"].get!string;
    }
    if ("api_ids" in payload && payload["api_ids"].isArray) {
      foreach (entry; payload["api_ids"]) {
        if (entry.isString) {
          product.apiIds ~= entry.get!string;
        }
      }
    }

    return product;
  }
}


