/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.tkc.models.taskaction;

import uim.sap.tkc;

mixin(ShowModule!());

@safe:

class TKCTaskAction : SAPEntity {
  mixin(SAPEntityTemplate!TKCTaskAction);

  string action;
  string performedBy;
  string comment;
  SysTime performedAt;

  override Json toJson() {
    return super.toJson
      .set("action", action)
      .set("performed_by", performedBy)
      .set("comment", comment)
      .set("performed_at", performedAt.toISOExtString());
  }
}
