module uim.sap.docmgmtintegration.helpers.helper;

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Check if a file extension is supported by the built-in viewer.
bool isViewableExtension(string fileName) {
  auto lower = toLower(fileName);
  foreach (ext; VIEWABLE_EXTENSIONS) {
    if (lower.endsWith(ext))
      return true;
  }
  return false;
}

/// Escape a value for CSV output.
string escapeCsv(string value) {
  auto escaped = value.replace("\"", "\"\"");
  return "\"" ~ escaped ~ "\"";
}
