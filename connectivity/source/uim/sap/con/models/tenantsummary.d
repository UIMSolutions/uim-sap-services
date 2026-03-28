/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.con.models.tenantsummary;

import uim.sap.con;

mixin(ShowModule!());

@safe:

class CONTenantSummary : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!CONTenantSummary);

  size_t destinations;

  override Json toJson() {
    return super.toJson()
      .set("destinations", cast(long)destinations);
  }
}
