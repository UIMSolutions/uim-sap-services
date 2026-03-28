module uim.sap.docmgmtintegration.enumerations.enumeration;

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

/// Supported content types for the built-in viewer.
enum string[] VIEWABLE_EXTENSIONS = [
    ".pdf", ".png", ".jpg", ".jpeg", ".gif", ".bmp", ".svg", ".webp"
  ];

/// Document workflow status.
enum DocumentStatus : string {
  draft = "draft",
  checkedOut = "checked_out",
  checkedIn = "checked_in",
  approved = "approved",
  archived = "archived"
}

/// CMIS base object types.
enum CmisObjectType : string {
  document = "cmis:document",
  folder = "cmis:folder"
}