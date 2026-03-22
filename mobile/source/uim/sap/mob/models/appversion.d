module uim.sap.mob.models.appversion;

import uim.sap.mob;

mixin(ShowModule!());

@safe:

/// Application version for OTA updates
struct MOBAppVersion {
  string versionId; // e.g. "1.2.0"
  string appId;
  MOBVersionStatus status = MOBVersionStatus.DRAFT;
  string releaseNotes;
  string packageUrl; // download URL for MDK bundle
  size_t packageSizeBytes;
  string checksum; // SHA-256 hash
  bool mandatoryUpdate;
  string minOsVersion;
  SysTime createdAt;
  SysTime activatedAt;

  override Json toJson()  {
    return super.toJson()
    .set("version_id", versionId)
    .set("app_id", appId)
    .set("status", cast(string)status)
    .set("release_notes", releaseNotes)
    .set("package_url", packageUrl)
    .set("package_size_bytes", cast(long)packageSizeBytes)
    .set("checksum", checksum)
    .set("mandatory_update", mandatoryUpdate)
    .set("min_os_version", minOsVersion)
    .set("created_at", createdAt.toISOExtString())
    .set("activated_at", activatedAt.toISOExtString());
  }
}

MOBAppVersion appVersionFromJson(string appId, string versionId, Json req) {
  MOBAppVersion ver;
  ver.versionId = versionId;
  ver.appId = appId;
  ver.createdAt = Clock.currTime();

  if ("release_notes" in req && req["release_notes"].isString)
    ver.releaseNotes = req["release_notes"].get!string;
  if ("package_url" in req && req["package_url"].isString)
    ver.packageUrl = req["package_url"].get!string;
  if ("package_size_bytes" in req && req["package_size_bytes"].isInteger)
    ver.packageSizeBytes = cast(size_t)req["package_size_bytes"].get!long;
  if ("checksum" in req && req["checksum"].isString)
    ver.checksum = req["checksum"].get!string;
  if ("mandatory_update" in req && req["mandatory_update"].isBoolean)
    ver.mandatoryUpdate = req["mandatory_update"].get!bool;
  if ("min_os_version" in req && req["min_os_version"].isString)
    ver.minOsVersion = req["min_os_version"].get!string;
  return ver;
}
