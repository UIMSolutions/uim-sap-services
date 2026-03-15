module uim.sap.rms.models.teams.team;

import uim.sap.rms;

mixin(ShowModule!());

@safe:

struct Team {
  string id;
  string name;
  string typeCode;
  string categoryCode;
  string description;
  TeamMember[] members;

  override Json toJson()  {
    Json info = super.toJson;
    payload["id"] = id;
    payload["name"] = name;
    payload["type_code"] = typeCode;
    payload["category_code"] = categoryCode;
    payload["description"] = description;

    Json memberList = Json.emptyArray;
    foreach (member; members) {
      memberList ~= member.toJson();
    }
    payload["members"] = memberList;
    return payload;
  }
}
