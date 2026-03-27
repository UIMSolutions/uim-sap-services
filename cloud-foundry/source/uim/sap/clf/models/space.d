/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.clf.models.space;

import uim.sap.clf;

mixin(ShowModule!());

@safe:
class CLFSpace : SAPObject {
  mixin(SAPObjectTemplate!CLFSpace);

  string guid;
  string name;
  string organizationGuid;

  override Json toJson() {
    return super.toJson
      .set("guid", guid)
      .set("name", name)
      .set("organization_guid", organizationGuid);
  }

  static CLFSpace opCall(Json payload) {
    CLFSpace space = new CLFSpace(payload);
    space.guId = randomUUID();
    space.createdAt = Clock.currTime();
    if ("name" in payload && payload["name"].isString) {
      space.name = payload["name"].getString;
    }
    if ("organization_guid" in payload && payload["organization_guid"].isString) {
      space.organizationGuid = payload["organization_guid"].getString;
    }
    return space;
  }
}
