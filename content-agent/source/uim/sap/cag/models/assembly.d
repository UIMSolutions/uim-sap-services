module uim.sap.cag.models.assembly;

import uim.sap.cag;

mixin(ShowModule!());

@safe:

class CAGAssembly : SAPTenantEntity {
  mixin(SAPTenantEntityTemplate!CAGAssembly);

  string assemblyId;
  string name;
  string sourceSubaccount;
  string targetSubaccount;
  string[] requestedContentIds;
  string[] resolvedContentIds;
  bool includeDependencies;
  string mtarName;
  string mtarDownloadUrl;
  string status;

  override Json toJson() {
    Json requested = Json.emptyArray;
    foreach (value; requestedContentIds)
      requested ~= value;

    Json resolved = Json.emptyArray;
    foreach (value; resolvedContentIds)
      resolved ~= value;

    return super.toJson
      .set("tenant_id", tenantId)
      .set("assembly_id", assemblyId)
      .set("name", name)
      .set("source_subaccount", sourceSubaccount)
      .set("target_subaccount", targetSubaccount)
      .set("requested_content_ids", requested)
      .set("resolved_content_ids", resolved)
      .set("include_dependencies", includeDependencies)
      .set("mtar_name", mtarName)
      .set("mtar_download_url", mtarDownloadUrl)
      .set("status", status);
  }
}
