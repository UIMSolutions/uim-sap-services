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
class PREItem {
  UUID itemId;
  UUID tenantId;
  string title;
  string description;
  string category;
  string[] tags;
  string[string] attributes;
  string imageUrl;
  double price = 0.0;
  PREItemStatus status = PREItemStatus.active;
  string createdAt;
  string updatedAt;
}

Json itemToJson(const ref PREItem i) {
  Json arr = Json.emptyArray;
  foreach (t; i.tags)
    arr ~= Json(t);

  Json obj = Json.emptyObject;
  foreach (k, v; i.attributes)
    obj[k] = v;

  return Json.emptyObject
    .set("itemId", i.itemId)
    .set("tenantId", i.tenantId)
    .set("title", i.title)
    .set("description", i.description)
    .set("category", i.category)
    .set("tags", arr)
    .set("attributes", obj)
    .set("imageUrl", i.imageUrl)
    .set("price", i.price)
    .set("status", i.status.to!string)
    .set("createdAt", i.createdAt)
    .set("updatedAt", i.updatedAt);
}

PREItem itemFromJson(Json json) {
  PREItem i;
  i.itemId = json["itemId"].get!string;
  i.tenantId = json.getString("tenantId", "");
  i.title = json.getString("title", "");
  i.description = json.getString("description", "");
  i.category = json.getString("category", "");
  if ("tags" in json) {
    foreach (t; json["tags"])
      i.tags ~= t.get!string;
  }
  if ("attributes" in json) {
    foreach (string k, v; json["attributes"].toMap)
      i.attributes[k] = v.get!string;
  }
  i.imageUrl = json.getString("imageUrl", "");
  if ("price" in json) {
    auto pv = json["price"];
    if (pv.isFloat)
      i.price = pv.get!double;
    else if (pv.isInteger)
      i.price = cast(double)pv.get!long;
  }
  return i;
}
