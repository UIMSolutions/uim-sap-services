/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.tkc.models.provider;

import uim.sap.tkc;

mixin(ShowModule!());

@safe:

class TKCProvider : SAPObject {
mixin(SAPObjectTemplate!TKCProvider);

  UUID providerId;
  string name;
  string providerType;
  string endpoint;
  bool active = true;
  bool hasLastSync;
  SysTime lastSyncAt;

  override Json toJson()  {
    return super.toJson
    .set("provider_id", providerId)
    .set("name", name)
    .set("provider_type", providerType)
    .set("endpoint", endpoint)
    .set("active", active)
    .set("last_sync_at", hasLastSync ? lastSyncAt.toISOExtString() : null);
  }
}
