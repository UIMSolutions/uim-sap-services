/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.featureflags.models.exportdata;

import uim.sap.featureflags;

mixin(ShowModule!());

@safe:

/** Container used for export/import of all flags from a tenant. */
class FFLExportData : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!FFLExportData);

  string exportedAt;
  string serviceVersion;
  FFLFlag[] flags;

  override Json toJson()  {
    Json arr = flags.map!(flag => flag.toJson()).array.toJson;

    return super.toJson()
      .set("tenant_id", tenantId)
      .set("exported_at", exportedAt)
      .set("service_version", serviceVersion)
      .set("flags", arr)
      .set("total_flags", cast(long)flags.length);
  }
}
