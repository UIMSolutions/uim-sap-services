/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.art.models.runtime.health;

import uim.sap.art;

mixin(ShowModule!());

@safe:

class ARTRuntimeHealth : SAPObject {
  mixin(SAPObjectTemplate!ARTRuntimeHealth);

  bool ok;
  string runtimeName;
  string runtimeVersion;
  size_t registeredPrograms;

  override Json toJson() {
    return super.toJson
    .set("ok", ok)
    .set("runtimeName", runtimeName)
    .set("runtimeVersion", runtimeVersion)
    .set("registeredPrograms", cast(long)registeredPrograms);
  }
}
