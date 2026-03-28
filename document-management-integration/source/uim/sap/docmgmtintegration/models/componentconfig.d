module uim.sap.docmgmtintegration.models.componentconfig;

// ---------------------------------------------------------------------------
// UI Component Configuration
// ---------------------------------------------------------------------------

/// Configuration for the embeddable UI5-based reusable document management component.
struct UIComponentConfig {
  UUID tenantId;
  UUID repositoryId;
  UUID rootFolderId;
  string componentName = "uim.sap.docmgmt.ReusableComponent";
  string componentVersion = "1.0.0";
  string theme = "sap_horizon";
  bool showBreadcrumbs = true;
  bool showVersionHistory = true;
  bool allowUpload = true;
  bool allowDelete = true;
  bool allowMove = true;
  bool allowCopy = true;
  bool showMetadata = true;
  bool showStatusManagement = true;
  int maxUploadSizeMB = 100;
  string locale = "en";

  override Json toJson() {
    Json r = Json.emptyObject;
    r["tenant_id"] = tenantId;
    r["repository_id"] = repositoryId;
    r["root_folder_id"] = rootFolderId;
    r["component_name"] = componentName;
    r["component_version"] = componentVersion;
    r["theme"] = theme;
    r["show_breadcrumbs"] = showBreadcrumbs;
    r["show_version_history"] = showVersionHistory;
    r["allow_upload"] = allowUpload;
    r["allow_delete"] = allowDelete;
    r["allow_move"] = allowMove;
    r["allow_copy"] = allowCopy;
    r["show_metadata"] = showMetadata;
    r["show_status_management"] = showStatusManagement;
    r["max_upload_size_mb"] = maxUploadSizeMB;
    r["locale"] = locale;
    return r;
  }

  UIComponentConfig uiConfigFromJson(UUID tenantId, Json request) {
  UIComponentConfig cfg;
  cfg.tenantId = tenantId;

  if ("repository_id" in request && request["repository_id"].isString)
    cfg.repositoryId = request["repository_id"].getString;
  if ("root_folder_id" in request && request["root_folder_id"].isString)
    cfg.rootFolderId = request["root_folder_id"].getString;
  if ("theme" in request && request["theme"].isString)
    cfg.theme = request["theme"].getString;
  if ("locale" in request && request["locale"].isString)
    cfg.locale = request["locale"].getString;
  if ("show_breadcrumbs" in request && request["show_breadcrumbs"].isBoolean)
    cfg.showBreadcrumbs = request["show_breadcrumbs"].get!bool;
  if ("show_version_history" in request && request["show_version_history"].isBoolean)
    cfg.showVersionHistory = request["show_version_history"].get!bool;
  if ("allow_upload" in request && request["allow_upload"].isBoolean)
    cfg.allowUpload = request["allow_upload"].get!bool;
  if ("allow_delete" in request && request["allow_delete"].isBoolean)
    cfg.allowDelete = request["allow_delete"].get!bool;
  if ("allow_move" in request && request["allow_move"].isBoolean)
    cfg.allowMove = request["allow_move"].get!bool;
  if ("allow_copy" in request && request["allow_copy"].isBoolean)
    cfg.allowCopy = request["allow_copy"].get!bool;
  if ("show_metadata" in request && request["show_metadata"].isBoolean)
    cfg.showMetadata = request["show_metadata"].get!bool;
  if ("show_status_management" in request && request["show_status_management"].type == Json
    .Type.bool_)
    cfg.showStatusManagement = request["show_status_management"].get!bool;
  if ("max_upload_size_mb" in request && request["max_upload_size_mb"].isInteger)
    cfg.maxUploadSizeMB = cast(int)request["max_upload_size_mb"].get!long;

  return cfg;
}
}