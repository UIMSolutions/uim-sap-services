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
  mixin(SAPTenantObjectTemplate!AEMTopicEvent);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("event_id" in initData && initData["event_id"].isString) {
      eventId = UUID(initData["event_id"].get!string);
    }

    if ("mesh_id" in initData && initData["mesh_id"].isString) {
      meshId = UUID(initData["mesh_id"].get!string);
    }

    if ("topic" in initData && initData["topic"].isString) {
      topic = initData["topic"].getString;
    }
    publisher = initData.getString("publisher", "unknown");
    payload = initData.getObject("payload", Json.emptyObject);

    return true;
  }

  UUID meshId;
  UUID eventId;
  string topic;
  string publisher;
  Json payload;
  SysTime publishedAt;

  override override Json toJson() {
    return super.toJson()
      .set("mesh_id", meshId.toJson)
      .set("event_id", eventId.toJson)
      .set("topic", topic)
      .set("publisher", publisher)
      .set("payload", payload)
      .set("published_at", publishedAt.toISOExtString());
  }
}

AEMTopicEvent eventFromJson(UUID tenantId, UUID meshId, Json request) {
  AEMTopicEvent event = new AEMTopicEvent(request);

  event.tenantId = tenantId;
  event.meshId = meshId;
  event.eventId = randomUUID();
  event.publishedAt = Clock.currTime();

  return event;
}
