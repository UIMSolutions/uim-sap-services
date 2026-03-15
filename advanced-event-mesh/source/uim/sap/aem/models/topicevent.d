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

  UUID meshId;
  UUID eventId;
  string topic;
  string publisher;
  Json payload = Json.emptyObject;
  SysTime publishedAt;

  override Json toJson() const {
    Json resultJson = super.toJson();

    resultJson["mesh_id"] = meshId.toJson;
    resultJson["event_id"] = eventId.toJson;
    resultJson["topic"] = topic;
    resultJson["publisher"] = publisher;
    resultJson["payload"] = payload;
    resultJson["published_at"] = publishedAt.toISOExtString();
    
    return resultJson;
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

  if ("event_id" in request && request["event_id"].isString) {
    e.eventId = UUID(request["event_id"].get!string);
  }
  if ("topic" in request && request["topic"].isString) {
    e.topic = request["topic"].get!string;
  }
  if ("publisher" in request && request["publisher"].isString) {
    e.publisher = request["publisher"].get!string;
  }
  if ("payload" in request) {
    e.payload = request["payload"];
  }

  return e;
}
