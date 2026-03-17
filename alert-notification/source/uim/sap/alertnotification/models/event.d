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

  UUID alertId;
  string eventType;
  string category;
  string severity;
  string source;
  string subject;
  string message;
  Json tags;
  Json payload = Json.emptyObject;

  override Json toJson()  {
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
  }  }
}