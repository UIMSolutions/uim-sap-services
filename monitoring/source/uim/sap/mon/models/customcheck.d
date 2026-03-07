/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.mon.models.customcheck;

import uim.sap.mon;

mixin(ShowModule!());

@safe:

struct MONCustomCheck {
  string checkId;
  string name;
  string targetType;
  string targetId;
  string endpoint;
  string method;
  int expectedStatus;
  SysTime createdAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["check_id"] = checkId;
    payload["name"] = name;
    payload["target_type"] = targetType;
    payload["target_id"] = targetId;
    payload["endpoint"] = endpoint;
    payload["method"] = method;
    payload["expected_status"] = expectedStatus;
    payload["created_at"] = createdAt.toISOExtString();
    return payload;
  }
}
