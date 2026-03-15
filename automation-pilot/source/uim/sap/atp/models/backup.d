module uim.sap.atp.models.backup;

import uim.sap.atp;

mixin(ShowModule!());

@safe:

class ATPBackup : SAPTenantObject {
  mixin(SAPObjectTemplate!ATPBackup);

  UUID backupId;
  string mode;
  Json content;

  override Json toJson() {
    Json payload = super.toJson;

    payload["backup_id"] = backupId;
    payload["mode"] = mode;
    payload["content"] = content;

    return payload;
  }
}
