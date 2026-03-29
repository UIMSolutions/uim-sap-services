/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.datasphere.models.integrationconnection;

import uim.sap.datasphere;

mixin(ShowModule!());

@safe:

/**
  * Represents an integration connection in the Datasphere system.
  *
  * This struct is used to store and manage information about integration connections,
  * which are used to connect Datasphere to external data sources or systems.
  * The struct includes fields for tenant ID, connection ID, name, source type, mode, security status 
  * and overall status of the connection.
  * 
  * Fields:
  * - tenantId: The ID of the tenant this connection belongs to.
  * - connectionId: A unique identifier for the integration connection.
  * - name: The name of the integration connection.
  * - sourceType: The type of the data source this connection is associated with (e.g., "HANA", "AWS S3").
  * - mode: The mode of the connection, which can be "federate", "replicate", or "transform_load".    
  * - secure: A boolean indicating whether the connection is secure (e.g., uses encryption).
  * - status: The current status of the connection (e.g., "active", "inactive", "error").
  * - updatedAt: The timestamp of the last update to this connection.  
  */
class DATIntegrationConnection : SAPTenantEntity  {
  mixin(SAPEntityTemplate!DATIntegrationConnection);

  UUID connectionId;
  string name;
  string sourceType;
  string mode;
  bool secure;
  string status;

  override Json toJson()  {
    return super.toJson
    .set("connection_id", connectionId)
    .set("name", name)
    .set("source_type", sourceType)
    .set("mode", mode)
    .set("secure", secure)
    .set("status", status);
  }
}
