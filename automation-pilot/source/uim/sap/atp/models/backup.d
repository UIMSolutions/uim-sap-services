module uim.sap.atp.models.backup;

import uim.sap.atp;

mixin(ShowModule!());

@safe:

/** 
  * Represents a backup of ATP data for a tenant. Contains the backup content and metadata.
  *
  * This class is used to store and retrieve ATP backup data, which can be used for disaster recovery or data migration purposes.
  *
  * Fields:
  * - backupId: Unique identifier for the backup.
  * - mode: The mode of the backup (e.g., "full", "incremental").
  * - content: The actual backup data, stored as JSON.
  * Methods:
  * - toJson(): Serializes the backup object to JSON format for storage or transmission.
  */
class ATPBackup : SAPTenantObject {
  mixin(SAPObjectTemplate!ATPBackup);

  UUID backupId;
  string mode;
  Json content;

  override Json toJson() {
    return super.toJson
      .set("backup_id", backupId)
      .set("mode", mode)
      .set("content", content);
  }
}
