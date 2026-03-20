/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.pre.models.interaction;

import uim.sap.pre;

mixin(ShowModule!());

@safe:

/// A recorded user–item interaction used for training and inference.
struct PREInteraction {
  string interactionId;
  string userId;
  string itemId;
  UUID tenantId;
  PREInteractionType interactionType = PREInteractionType.view;
  double weight = 1.0;
  string[string] context;
  string timestamp;
}

Json interactionToJson(const ref PREInteraction i) {
  Json j = Json.emptyObject;
  j["interactionId"] = i.interactionId;
  j["userId"] = i.userId;
  j["itemId"] = i.itemId;
  j["tenantId"] = i.tenantId;
  j["interactionType"] = i.interactionType.to!string;
  j["weight"] = i.weight;
  {
    Json obj = Json.emptyObject;
    foreach (k, v; i.context)
      obj[k] = v;
    j["context"] = obj;
  }
  j["timestamp"] = i.timestamp;
  return j;
}

PREInteraction interactionFromJson(Json j) {
  PREInteraction i;
  i.interactionId = j.getString("interactionId", "");
  i.userId = j["userId"].get!string;
  i.itemId = j["itemId"].get!string;
  i.tenantId = j.getString("tenantId", "");
  if ("weight" in j) {
    auto wv = j["weight"];
    if (wv.isFloat)
      i.weight = wv.get!double;
    else if (wv.isInteger)
      i.weight = cast(double)wv.get!long;
  }
  if ("context" in j) {
    foreach (string k, v; j["context"].toMap)
      i.context[k] = v.get!string;
  }
  return i;
}
