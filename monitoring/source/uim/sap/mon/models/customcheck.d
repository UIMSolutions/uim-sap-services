/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.mon.models.customcheck;

import uim.sap.mon;

mixin(ShowModule!());

@safe:

class MONCustomCheck : SAPEntity {
  mixin(SAPEntityTemplate!MONCustomCheck);

  UUID checkId;
  string name;
  string targetType;
  UUID targetId;
  string endpoint;
  string method;
  int expectedStatus;
  SysTime createdAt;

  override Json toJson()  {
    return super.toJson
    .set("check_id", checkId)
    .set("name", name)
    .set("target_type", targetType)
    .set("target_id", targetId)
    .set("endpoint", endpoint)
    .set("method", method)
    .set("expected_status", expectedStatus);
  }
}
