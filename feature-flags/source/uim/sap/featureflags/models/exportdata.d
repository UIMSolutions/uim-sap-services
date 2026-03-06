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
