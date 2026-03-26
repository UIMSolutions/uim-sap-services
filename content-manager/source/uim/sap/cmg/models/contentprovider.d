/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cmg.models.contentprovider;

import uim.sap.cmg;

mixin(ShowModule!());

@safe:

class CMGContentProvider : SAPTenantObject {
  mixin(SAPObjectTemplate!CMGContentProvider);

  UUID providerId;
  string name;
  string providerType;
  string endpoint;
  string[] exposedTypes;
  bool active;

  override Json toJson()  {
    Json typeValues = exposedTypes.map!(val => val).toJson;

    return super.toJson
      .set("provider_id", providerId)
      .set("name", name)
      .set("provider_type", providerType)
      .set("endpoint", endpoint)
      .set("exposed_types", typeValues)
      .set("active", active);
  }
}
