/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.pre.models.item;

import uim.sap.pre;

mixin(ShowModule!());

@safe:

/// A catalog item that can be recommended.
class PREItem : SAPTenantEntity {
  mixin(SAPTenantEntity!PREItem);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }
    if ("itemId" in initData && initData["itemId"].isString) {
      itemId = UUID(initData["itemId"].getString);
    }
    if ("title" in initData && initData["title"].isString) {
      title = initData["title"].getString;
    }
    if ("description" in initData && initData["description"].isString) {
      description = initData["description"].getString;
    }
    if ("category" in initData && initData["category"].isString) {
      category = initData["category"].getString;
    }
    if ("tags" in initData && initData["tags"].isArray) {
      foreach (Json tag; initData["tags"].toArray)
        if (tag.isString)
          tags ~= tag.getString;
    }
    if ("attributes" in initData && initData["attributes"].isObject) {
      foreach (k, v; initData["attributes"].toObject) {
        if (v.isString)
          attributes[k] = v.getString;
      }
    }
    if ("imageUrl" in initData && initData["imageUrl"].isString) {
      imageUrl = initData["imageUrl"].getString;
    }
    if ("price" in initData && (initData["price"].isDouble || initData["price"].isInt)) {
      price = initData["price"].get!double;
    }
    if ("status" in initData && initData["status"].isString) {
      status = PREItemStatus.fromString(initData["status"].getString);
    }

    i.itemId = json["itemId"].getString;
    i.tenantId = json.getString("tenantId", "");
    i.title = json.getString("title", "");
    i.description = json.getString("description", "");
    i.category = json.getString("category", "");
    if ("tags" in json) {
      foreach (t; json["tags"])
        i.tags ~= t.getString;
    }
    if ("attributes" in json) {
      foreach (string k, v; json["attributes"].toMap)
        i.attributes[k] = v.getString;
    }
    i.imageUrl = json.getString("imageUrl", "");
    if ("price" in json) {
      auto pv = json["price"];
      if (pv.isFloat)
        i.price = pv.get!double;
      else if (pv.isInteger)
        i.price = cast(double)pv.get!long;
    }

    return true;
  }

  UUID itemId;
  string title;
  string description;
  string category;
  string[] tags;
  string[string] attributes;
  string imageUrl;
  double price = 0.0;
  PREItemStatus status = PREItemStatus.active;

  Json toJson(const ref PREItem i) {
    Json arr = Json.emptyArray;
    foreach (t; tags)
      arr ~= Json(t);

    Json obj = Json.emptyObject;
    foreach (k, v; attributes)
      obj[k] = v;

    return super.toJson()
      .set("itemId", itemId)
      .set("title", title)
      .set("description", description)
      .set("category", category)
      .set("tags", arr)
      .set("attributes", obj)
      .set("imageUrl", imageUrl)
      .set("price", price)
      .set("status", status.to!string);
  }

  PREItem itemFromJson(Json json) {
    PREItem i = new PREItem(json);

    return i;
  }
}
