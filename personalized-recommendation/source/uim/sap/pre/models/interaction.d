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
class PREInteraction : SAPTenantObject {
  mixin(SAPObjectTemplate!PREInteraction);

  UUID interactionId;
  UUID userId;
  UUID itemId;
  PREInteractionType interactionType = PREInteractionType.view;
  double weight = 1.0;
  string[string] context;
  string timestamp;

  override Json toJson() {
    Json obj = Json.emptyObject;
    foreach (k, v; context)
      obj[k] = v;

    return super.toJson()
      .set("interactionId", interactionId)
      .set("userId", userId)
      .set("itemId", itemId)
      .set("tenantId", tenantId)
      .set("interactionType", interactionType.to!string)
      .set("weight", weight)
      .set("context", obj)
      .set("timestamp", timestamp);
  }

  static PREInteraction opCall(Json settings) {
    PREInteraction i = new PREInteraction(settings);
    i.interactionId = settings.getString("interactionId", "");
    i.userId = settings.getString("userId");
    i.itemId = settings.getString("itemId");
    i.tenantId = settings.getString("tenantId", "");
    if ("weight" in settings) {
      auto wv = settings["weight"];
      if (wv.isFloat)
        i.weight = wv.get!double;
      else if (wv.isInteger)
        i.weight = cast(double)wv.get!long;
    }
    if ("context" in settings) {
      foreach (string k, v; settings["context"].toMap)
        i.context[k] = v.getString;
    }
    return i;
  }
}
