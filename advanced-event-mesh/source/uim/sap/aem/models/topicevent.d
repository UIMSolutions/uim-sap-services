/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.aem.models.topicevent;

import uim.sap.aem;

mixin(ShowModule!());

@safe:

class AEMTopicEvent : SAPTenantObject {
  mixin(SAPObjectTemplate!AEMTopicEvent);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

      if ("event_id" in initData && initData["event_id"].isString) {
    eventId = UUID(initData["event_id"].get!string);
  }
  if ("topic" in initData && initData["topic"].isString) {
    topic = initData["topic"].get!string;
  }
  if ("publisher" in initData && initData["publisher"].isString) {
    publisher = initData["publisher"].get!string;
  }
  if ("payload" in initData) {
    payload = initData["payload"];
  }

  return true;
  }

  UUID meshId;
  UUID eventId;
  string topic;
  string publisher;
  Json payload = Json.emptyObject;
  SysTime publishedAt;

  override override Json toJson()  {
    return super.toJson()
      .set("mesh_id", meshId.toJson)
      .set("event_id", eventId.toJson)
      .set("topic", topic)
      .set("publisher", publisher)
      .set("payload", payload)
      .set("published_at", publishedAt.toISOExtString());
  }
}

AEMTopicEvent eventFromJson(string tenantId, string meshId, Json request) {
  AEMTopicEvent e = new AEMTopicEvent();
  e.tenantId = UUID(tenantId);
  e.meshId = UUID(meshId);
  e.eventId = randomUUID();
  e.publisher = "unknown";
  e.payload = Json.emptyObject;
  e.publishedAt = Clock.currTime();

  return e;
}
