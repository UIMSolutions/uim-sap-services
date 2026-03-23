module uim.sap.dma.models.models;

import std.algorithm.searching : canFind;
import std.array : appender;
import std.datetime : Clock, SysTime;
import std.string : replace, toLower, endsWith;
import std.uuid : randomUUID;

import vibe.data.json : Json;

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

// ---------------------------------------------------------------------------
// Repository
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// DMAFolder
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Document
// ---------------------------------------------------------------------------


}


// ---------------------------------------------------------------------------
// Document Version
// ---------------------------------------------------------------------------



// ---------------------------------------------------------------------------
// Breadcrumb
// ---------------------------------------------------------------------------



// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Check if a file extension is supported by the built-in viewer.
bool isViewableExtension(string fileName) {
  auto lower = toLower(fileName);
  foreach (ext; VIEWABLE_EXTENSIONS) {
    if (lower.endsWith(ext)) {
      return true;
    }
  }
  return false;
}

/// Escape a value for CSV output.
string escapeCsv(string value) {
  auto escaped = value.replace("\"", "\"\"");
  return "\"" ~ escaped ~ "\"";
}
