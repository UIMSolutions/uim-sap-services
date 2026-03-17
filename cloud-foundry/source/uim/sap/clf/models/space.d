/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.clf.models.space;

import uim.sap.clf;

mixin(ShowModule!());

@safe:
struct CLFSpace {
  string guid;
  string name;
  string organizationGuid;

  override Json toJson()  {
    return super.toJson
    .set"guid", guid)
    .set"name", name)
    .set"organization_guid", organizationGuid);
  }
}

CLFSpace spaceFromJson(Json payload) {
  CLFSpace space = new CLFSpace(payload);
  space.guid = randomUUID().toString();
  space.createdAt = Clock.currTime();
  if ("name" in payload && payload["name"].isString) {
    space.name = payload["name"].get!string;
  }
  if ("organization_guid" in payload && payload["organization_guid"].isString) {
    space.organizationGuid = payload["organization_guid"].get!string;
  }
  return space;
}
