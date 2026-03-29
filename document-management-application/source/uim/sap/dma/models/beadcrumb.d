module uim.sap.dma.models.breadcrumb;

import uim.sap.dma;

mixin(ShowModule!());

@safe:

/// A single step in a breadcrumb path.
class DMABreadcrumb : SAPEntity {
  UUID folderId;
  string name;

  override Json toJson() {
    return super.toJson()
      .set("folder_id", folderId)
      .set("name", name);
  }
}