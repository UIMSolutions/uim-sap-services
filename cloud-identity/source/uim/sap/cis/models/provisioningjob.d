/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cis.models.provisioningjob;

import uim.sap.cis;

mixin(ShowModule!());

@safe:

/** 
  * Model representing a provisioning job in the UIM Cloud Identity Services (CIS) module.
  * This struct defines the properties of a provisioning job, including the tenant ID, job ID, source system, target system, mode, status, filters, and timestamps for creation and updates.
  * The `toJson()` method is provided to serialize the provisioning job into a JSON format for API responses or storage purposes.
  * Fields:
  * - `tenantId`: The ID of the tenant this provisioning job belongs to.
  * - `jobId`: The unique ID of the provisioning job.
  * - `sourceSystem`: The source system from which data is being provisioned (e.g., "application", "database").
  * - `targetSystem`: The target system to which data is being provisioned (e.g., "cloud", "on-premise").
  * - `mode`: The mode of the provisioning job (e.g., "full", "delta").
  * - `status`: The current status of the provisioning job (e.g., "pending", "running", "completed", "failed").
  * - `filters`: A JSON object containing any filters applied to the provisioning job (e.g., specific user groups or attributes).
  * - `createdAt`: The timestamp of when the provisioning job was created.
  * - `updatedAt`: The timestamp of when the provisioning job was last updated.
  * Methods:
  * - `toJson()`: Converts the provisioning job to a JSON object for API responses or storage.
  * Example usage:
  * ```
  * CISProvisioningJob job;
  * job.tenantId = "tenant123";
  * job.jobId = "job456";
  * job.sourceSystem = "application";
  * job.targetSystem = "cloud";
  * job.mode = "full";
  * job.status = "pending";
  * job.filters = Json({"group": "test-group"});
  * job.createdAt = Clock.currTime();
  * job.updatedAt = Clock.currTime();
  * Json jobJson = job.toJson();
  * ```
  * Note: The `toJson()` method is used to serialize the provisioning job into a JSON format that can be returned in API responses or stored in a database. The actual implementation of the `toJson()` method may vary based on the specific requirements of the application and the structure of the JSON payload expected by the
  */
struct CISProvisioningJob {
  UUID tenantId;
  UUID jobId;
  string sourceSystem;
  string targetSystem;
  string mode;
  string status;
  Json filters;
  SysTime createdAt;
  SysTime updatedAt;

  override Json toJson()  {
    Json info = super.toJson;
    payload["job_id"] = jobId;
    payload["tenant_id"] = tenantId;
    payload["source_system"] = sourceSystem;
    payload["target_system"] = targetSystem;
    payload["mode"] = mode;
    payload["status"] = status;
    payload["filters"] = filters;
    payload["created_at"] = createdAt.toISOExtString();
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}
