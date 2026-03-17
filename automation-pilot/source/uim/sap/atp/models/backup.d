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
///
unittest {
  mixin(ShowTest!("ATPBackup JSON Serialization Test"));

  ATPBackup backup = new ATPBackup();
  backup.tenantId = UUID("123e4567-e89b-12d3-a456-426614174000");
  backup.backupId = UUID("123e4567-e89b-12d3-a456-426614174001");
  backup.mode = "full";
  backup.content = [
    {"commandId": "cmd1", "data": "sample data 1"}, 
    {"commandId": "cmd2", "data": "sample data 2"}
  ].toJson(); 

  Json json = backup.toJson();
  assert(json["tenant_id"] == backup.tenantId.toString());
  assert(json["backup_id"] == backup.backupId.toString());
  assert(json["mode"] == backup.mode);
  assert(json["content"] == backup.content);  
}