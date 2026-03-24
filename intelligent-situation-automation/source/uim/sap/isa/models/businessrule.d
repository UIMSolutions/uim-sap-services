/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.isa.models.businessrule;

import uim.sap.isa;

mixin(ShowModule!());

@safe:

struct BusinessRule {
  string field;
  string op;
  string expected;

  override Json toJson()  {
    return super.toJson()
      .set("field", field)
      .set("op", op)
      .set("expected", expected);
  }
}

private BusinessRule[] parseRules(Json payload) {
  BusinessRule[] rules;
  if (!("business_rules" in payload) || !payload["business_rules"].isArray) {
    return rules;
  }

  foreach (entry; payload["business_rules"]) {
    if (!entry.isObject) {
      continue;
    }

    BusinessRule rule;
    rule.field = getString(entry, "field", "");
    rule.op = getString(entry, "op", "equals");
    rule.expected = getString(entry, "expected", "");

    if (rule.field.length == 0) {
      continue;
    }
    rules ~= rule;
  }

  return rules;
}