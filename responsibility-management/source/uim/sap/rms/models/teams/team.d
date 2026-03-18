module uim.sap.rms.models.teams.team;

import uim.sap.rms;

mixin(ShowModule!());

@safe:

class Team : SAPObject {
mixin(SAPObjectTemplate!Team);

  string id;
  string name;
  string typeCode;
  string categoryCode;
  string description;
  TeamMember[] members;

  override Json toJson()  {
    return super.toJson
    .set("id", id)
    .set("name", name)
    .set("type_code", typeCode)
    .set("category_code", categoryCode)
    .set("description", description);

    Json memberList = Json.emptyArray;
    foreach (member; members) {
      memberList ~= member.toJson();
    }
    payload["members"] = memberList;
    return payload;
  }
}
