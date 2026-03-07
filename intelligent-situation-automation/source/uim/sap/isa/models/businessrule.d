/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.isa.models.businessrule;

struct BusinessRule {
  string field;
  string op;
  string expected;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["field"] = field;
    payload["op"] = op;
    payload["expected"] = expected;
    return payload;
  }
}