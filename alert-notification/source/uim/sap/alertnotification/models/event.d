/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.alertnotification.models.event;

import uim.sap.alertnotification;

mixin(ShowModule!());

@safe:
class AlertEvent : SAPTenantObject {
  mixin(SAPObjectTemplate!AlertEvent);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("alert_id" in initData && initData["alert_id"].isString) {
      alertId = UUID(initData["alert_id"].get!string);
    } else {
      alertId = randomUUID();
    }

    eventType = initData.getString("event_type", "");
    category = initData.getString("category", "");
    severity = initData.getString("severity", "");
    source = initData.getString("source", "");
    subject = initData.getString("subject", "");
    message = initData.getString("message", "");

    tags = initData.getObject("tags", Json.emptyObject);
    payload = initData.getObject("payload", Json.emptyObject);

    return true;
  }

  UUID alertId;
  string eventType;
  string category;
  string severity;
  string source;
  string subject;
  string message;
  Json tags;
  Json payload;

  override Json toJson() {
    return super.toJson()
      .set("alert_id", alertId.toJson())
      .set("event_type", eventType.toJson())
      .set("category", category.toJson())
      .set("severity", severity.toJson())
      .set("source", source.toJson())
      .set("subject", subject.toJson())
      .set("message", message.toJson())
      .set("tags", tags.toJson())
      .set("payload", payload.toJson());
  }
}
