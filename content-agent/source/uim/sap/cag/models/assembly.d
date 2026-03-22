module uim.sap.cag.models.assembly;

struct CAGAssembly {
  UUID tenantId;
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
  SysTime createdAt;
  SysTime updatedAt;

  override Json toJson() {
    Json payload = Json.emptyObject
      .set("tenant_id", tenantId)
      .set("assembly_id", assemblyId)
      .set("name", name)
      .set("source_subaccount", sourceSubaccount)
      .set("target_subaccount", targetSubaccount);

    Json requested = Json.emptyArray;
    foreach (value; requestedContentIds)
      requested ~= value;
    payload["requested_content_ids"] = requested;

    Json resolved = Json.emptyArray;
    foreach (value; resolvedContentIds)
      resolved ~= value;
    payload["resolved_content_ids"] = resolved;

    payload["include_dependencies"] = includeDependencies;
    payload["mtar_name"] = mtarName;
    payload["mtar_download_url"] = mtarDownloadUrl;
    payload["status"] = status;
    payload["created_at"] = createdAt.toISOExtString();
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}