module uim.sap.slm.models.models;

import uim.sap.slm;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// SLMSolution – a deployed solution in a subaccount
// ---------------------------------------------------------------------------
struct SLMSolution {
  UUID tenantId;
  UUID solutionId;
  string name;
  string description;
  /// MTA ID of the deployed Multi-Target Application
  UUID mtaId;
  /// Current version string
  string mtaVersion;
  /// Status: "deploying" | "deployed" | "updating" | "error" | "deleting" | "deleted"
  string status;
  /// Global account and subaccount identifiers
  UUID globalAccountId;
  UUID subaccountId;
  /// Space / org in Cloud Foundry
  UUID spaceId;
  UUID orgId;
  /// Whether this solution is multitenant
  bool multitenant;
  /// The user who deployed the solution
  string deployedBy;
  SysTime createdAt;
  SysTime updatedAt;

  override Json toJson() {
    return super.toJson()
      .set("tenant_id", tenantId)
      .set("solution_id", solutionId)
      .set("name", name)
      .set("description", description)
      .set("mta_id", mtaId)
      .set("mta_version", mtaVersion)
      .set("status", status)
      .set("global_account_id", globalAccountId)
      .set("subaccount_id", subaccountId)
      .set("space_id", spaceId)
      .set("org_id", orgId)
      .set("multitenant", multitenant)
      .set("deployed_by", deployedBy)
      .set("created_at", createdAt.toISOExtString())
      .set("updated_at", updatedAt.toISOExtString());
  }
}

// ---------------------------------------------------------------------------
// SLMComponent – an individual component of a deployed solution
// ---------------------------------------------------------------------------
struct SLMComponent {
  UUID solutionId;
  UUID componentId;
  string name;
  /// Type: "app" | "service-instance" | "service-binding" | "content" | "module" | "resource"
  string componentType;
  /// Status: "started" | "stopped" | "error" | "staging" | "crashed"
  string status;
  /// Runtime URL or endpoint
  string url;
  /// Memory in MB
  int memoryMb;
  /// Number of running instances
  int instances;
  SysTime createdAt;
  SysTime updatedAt;

  Json toJson() {
    return Json.emptyObject
      .set("solution_id", solutionId)
      .set("component_id", componentId)
      .set("name", name)
      .set("component_type", componentType)
      .set("status", status)
      .set("url", url)
      .set("memory_mb", memoryMb)
      .set("instances", instances)
      .set("created_at", createdAt.toISOExtString())
      .set("updated_at", updatedAt.toISOExtString());
  }
}

// ---------------------------------------------------------------------------
// SLMDeployment – a deployment/update operation record
// ---------------------------------------------------------------------------
class SLMDeployment : SAPTenantObject {
  mixin(SAPObjectTemplate!SLMDeployment);

  UUID deploymentId;
  UUID solutionId;
  /// MTA archive reference (file path or URL)
  string mtaArchiveRef;
  string mtaVersion;
  /// Action: "deploy" | "update" | "delete"
  string action;
  /// Status: "scheduled" | "running" | "succeeded" | "failed" | "cancelled"
  string status;
  string triggeredBy;
  /// Error message if failed
  string errorMessage;
  SysTime startedAt;
  SysTime finishedAt;

  override Json toJson() {
    return super.toJson()
      .set("deployment_id", deploymentId)
      .set("solution_id", solutionId)
      .set("mta_archive_ref", mtaArchiveRef)
      .set("mta_version", mtaVersion)
      .set("action", action)
      .set("status", status)
      .set("triggered_by", triggeredBy)
      .set("error_message", errorMessage)
      .set("started_at", startedAt.toISOExtString())
      .set("finished_at", finishedAt.toISOExtString());
  }
}





