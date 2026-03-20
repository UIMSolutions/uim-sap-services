module uim.sap.mdi.models.replicationjob;

import uim.sap.mdi;

mixin(ShowModule!());

@safe:

/**
  * Represents a replication job in the Master Data Integration (MDI) system.
  * Each job defines the parameters for replicating master data from a source client to a target client, including the object type, mode, status, and any filters applied.
  *
  * Example usage:
  * ```
  * MDIReplicationJob job;
  * job.tenantId = "tenant123";
  * job.jobId = "job456";
  * job.sourceClientId = "sourceClient789";
  * job.targetClientId = "targetClient012";
  * job.objectType = "Product";
  * job.mode = "full";
  * job.status = "scheduled";
  * job.filterIds = Json(["filter1", "filter2"]);
  * job.createdAt = Clock.currTime();
  * job.updatedAt = Clock.currTime();
  * ```
  * Fields:
  * - `tenantId`: The ID of the tenant to which this replication job belongs.
  * - `jobId`: A unique identifier for the replication job.
  * - `sourceClientId`: The client ID from which data will be replicated.
  * - `targetClientId`: The client ID to which data will be replicated. 
  * - `objectType`: The type of object being replicated (e.g., "Product", "Customer").
  * - `mode`: The mode of replication (e.g., "full", "delta update").
  * - `status`: The current status of the replication job (e.g., "scheduled", "in progress", "completed", "failed").
  * - `filterIds`: A JSON array containing the IDs of filters applied to this replication job.
  * - `createdAt`: A timestamp indicating when the replication job was created.
  * - `updatedAt`: A timestamp indicating when the replication job was last updated.
 */ 
struct MDIReplicationJob {
    UUID tenantId;
    string jobId;
    string sourceClientId;
    string targetClientId;
    string objectType;
    string mode;
    string status;
    Json filterIds;
    SysTime createdAt;
    SysTime updatedAt;

    override Json toJson()  {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["job_id"] = jobId;
        payload["source_client_id"] = sourceClientId;
        payload["target_client_id"] = targetClientId;
        payload["object_type"] = objectType;
        payload["mode"] = mode;
        payload["status"] = status;
        payload["filter_ids"] = filterIds;
        payload["created_at"] = createdAt.toISOExtString();
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}