/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.clf.models.services.instance;

import uim.sap.clf;

mixin(ShowModule!());

@safe:
class CLFServiceInstance : SAPObject {
  mixin(SAPObjectTemplate!CLFServiceInstance);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("guid" in initData && initData["guid"].isString) {
      guid = initData["guid"].get!string;
    }

    if ("name" in initData && initData["name"].isString) {
      name = initData["name"].get!string;
    }
    
    if ("service_guid" in payload && payload["service_guid"].isString) {
      instance.serviceGuid = payload["service_guid"].get!string;
    }
    
    if ("space_guid" in payload && payload["space_guid"].isString) {
      instance.spaceGuid = payload["space_guid"].get!string;
    }

    status = initData.getSString("status", "create succeeded");
    return true;
  }

  string guid;
  string name;
  string serviceGuid;
  string spaceGuid;
  string status = "create succeeded";
  SysTime createdAt;

  override Json toJson() {
    return super.toJson()
    .set("guid", guid)
    .set("name", name)
    .set("service_guid", serviceGuid)
    .set("space_guid", spaceGuid)
    .set("status", status);
  }

  CLFServiceInstance opCall(Json payload) {
    CLFServiceInstance instance = new CLFServiceInstance(payload);

    instance.guid = randomUUID().toString();
    instance.createdAt = Clock.currTime();
    return instance;
  }
}
