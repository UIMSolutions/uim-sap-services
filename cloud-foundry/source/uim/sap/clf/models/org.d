/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.clf.models.org;

import uim.sap.clf;

mixin(ShowModule!());

@safe:
class CLFOrg : SAPEntity {
  mixin(SAPEntityTemplate!CLFOrg);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("name" in initData && initData["name"].isString) {
      name = initData["name"].getString;
    }

    return true;
  }

  string guid;
  string name;

  override Json toJson() {
    return super.toJson()
      .set("guid", guid)
      .set("name", name);
  }

  static CLFOrg opCall(Json payload) {
    CLFOrg org = new CLFOrg(payload);
    org.guId = randomUUID();
    org.createdAt = Clock.currTime();
    return org;
}
}


