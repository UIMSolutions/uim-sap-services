/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.clf.models.services.instance;

import uim.sap.clf;

mixin(ShowModule!());

@safe:
struct CLFServiceInstance {
  string guid;
  string name;
  string serviceGuid;
  string spaceGuid;
  string status = "create succeeded";
  SysTime createdAt;

  override Json toJson()  {
    Json info = super.toJson;
    payload["guid"] = guid;
    payload["name"] = name;
    payload["service_guid"] = serviceGuid;
    payload["space_guid"] = spaceGuid;
    payload["status"] = status;
    payload["created_at"] = createdAt.toISOExtString();
    return payload;
  }

CLFServiceInstance opCall(Json payload) {
  CLFServiceInstance instance;
  instance.guid = randomUUID().toString();
  instance.createdAt = Clock.currTime();
  if ("name" in payload && payload["name"].isString) {
    instance.name = payload["name"].get!string;
  }
  if ("service_guid" in payload && payload["service_guid"].isString) {
    instance.serviceGuid = payload["service_guid"].get!string;
  }
  if ("space_guid" in payload && payload["space_guid"].isString) {
    instance.spaceGuid = payload["space_guid"].get!string;
  }
  return instance;
}
}