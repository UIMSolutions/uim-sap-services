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
struct FFLExportData {
    string tenantId;
    string exportedAt;
    string serviceVersion;
    FFLFlag[] flags;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"] = tenantId;
        j["exported_at"] = exportedAt;
        j["service_version"] = serviceVersion;

        Json arr = Json.emptyArray;
        foreach (flag; flags) {
            arr ~= flag.toJson();
        }
        j["flags"] = arr;
        j["total_flags"] = cast(long) flags.length;
        return j;
    }
}
