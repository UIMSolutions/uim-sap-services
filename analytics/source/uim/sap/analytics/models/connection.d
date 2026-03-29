/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.analytics.models.connection;
import uim.sap.analytics;

mixin(ShowModule!());

@safe:

class AnalyticsConnection : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!AnalyticsConnection);

  string connectionId;
  string name;
  string description;
  string connectionType; // "live", "import", "blend"
  string sourceSystem;   // "sap_hana", "sap_bw", "sap_s4hana", "sap_datasphere", "odata", "csv", "database"
  string host;
  ushort port;
  string database;
  string schema;
  string status;         // "connected", "disconnected", "error"
  bool sslEnabled;
  Json metadata;         // additional connection properties
  SysTime createdAt;
  SysTime lastTestedAt;

  override Json toJson() {
    return super.toJson()
      .set("connection_id", connectionId)
      .set("name", name)
      .set("description", description)
      .set("connection_type", connectionType)
      .set("source_system", sourceSystem)
      .set("host", host)
      .set("port", cast(long) port)
      .set("database", database)
      .set("schema", schema)
      .set("status", status)
      .set("ssl_enabled", sslEnabled)
      .set("metadata", metadata)
      .set("created_at", createdAt.toISOExtString())
      .set("last_tested_at", lastTestedAt.toISOExtString());
  }
}
