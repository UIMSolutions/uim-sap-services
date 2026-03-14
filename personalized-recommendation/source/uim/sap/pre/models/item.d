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
struct PREItem {
    string itemId;
    string tenantId;
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
    Json j = Json.emptyObject;
    j["itemId"] = i.itemId;
    j["tenantId"] = i.tenantId;
    j["title"] = i.title;
    j["description"] = i.description;
    j["category"] = i.category;
    {
        Json arr = Json.emptyArray;
        foreach (t; i.tags)
            arr ~= Json(t);
        j["tags"] = arr;
    }
    {
        Json obj = Json.emptyObject;
        foreach (k, v; i.attributes)
            obj[k] = v;
        j["attributes"] = obj;
    }
    j["imageUrl"] = i.imageUrl;
    j["price"] = i.price;
    j["status"] = i.status.to!string;
    j["createdAt"] = i.createdAt;
    j["updatedAt"] = i.updatedAt;
    return j;
}

PREItem itemFromJson(Json j) {
    PREItem i;
    i.itemId = j["itemId"].get!string;
    i.tenantId = j.getOrDefault!string("tenantId", "");
    i.title = j.getOrDefault!string("title", "");
    i.description = j.getOrDefault!string("description", "");
    i.category = j.getOrDefault!string("category", "");
    if ("tags" in j) {
        foreach (t; j["tags"])
            i.tags ~= t.get!string;
    }
    if ("attributes" in j) {
        foreach (string k, v; j["attributes"])
            i.attributes[k] = v.get!string;
    }
    i.imageUrl = j.getOrDefault!string("imageUrl", "");
    if ("price" in j) {
        auto pv = j["price"];
        if (pv.type == Json.Type.float_)
            i.price = pv.get!double;
        else if (pv.type == Json.Type.int_)
            i.price = cast(double) pv.get!long;
    }
    return i;
}
