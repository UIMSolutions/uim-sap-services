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
struct SLMDeployment {
  UUID tenantId;
  string deploymentId;
  string solutionId;
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

  Json toJson() {
    Json j = Json.emptyObject;
    j["tenant_id"] = tenantId;
    j["deployment_id"] = deploymentId;
    j["solution_id"] = solutionId;
    j["mta_archive_ref"] = mtaArchiveRef;
    j["mta_version"] = mtaVersion;
    j["action"] = action;
    j["status"] = status;
    j["triggered_by"] = triggeredBy;
    j["error_message"] = errorMessage;
    j["started_at"] = startedAt.toISOExtString();
    j["finished_at"] = finishedAt.toISOExtString();
    return j;
  }
}

// ---------------------------------------------------------------------------
// SLMSubscription – a multitenant subscription from a consumer subaccount
// ---------------------------------------------------------------------------
struct SLMSubscription {
  UUID tenantId;
  string subscriptionId;
  string solutionId;
  /// The subscribing (consumer) subaccount
  string consumerSubaccountId;
  string consumerTenantId;
  /// Status: "subscribed" | "unsubscribing" | "unsubscribed" | "error"
  string status;
  /// License entitlement reference
  string entitlementId;
  string subscribedBy;
  SysTime subscribedAt;
  SysTime unsubscribedAt;

  Json toJson() {
    Json j = Json.emptyObject;
    j["tenant_id"] = tenantId;
    j["subscription_id"] = subscriptionId;
    j["solution_id"] = solutionId;
    j["consumer_subaccount_id"] = consumerSubaccountId;
    j["consumer_tenant_id"] = consumerTenantId;
    j["status"] = status;
    j["entitlement_id"] = entitlementId;
    j["subscribed_by"] = subscribedBy;
    j["subscribed_at"] = subscribedAt.toISOExtString();
    j["unsubscribed_at"] = unsubscribedAt.toISOExtString();
    return j;
  }
}

// ---------------------------------------------------------------------------
// SLMLicense – license information associated with a solution
// ---------------------------------------------------------------------------
struct SLMLicense {
  UUID tenantId;
  string licenseId;
  string solutionId;
  /// Plan: e.g., "standard", "enterprise"
  string plan;
  /// Quota limit (e.g., number of users or API calls)
  long quotaLimit;
  long quotaUsed;
  string status; // "active" | "expired" | "suspended"
  SysTime validFrom;
  SysTime validUntil;

  Json toJson() {
    return super.toJson()
     .set("tenant_id", tenantId)
     .set("license_id", licenseId)
     .set("solution_id", solutionId)
     .set("plan", plan)
     .set("quota_limit", quotaLimit)
     .set("quota_used", quotaUsed)
     .set("status", status)
     .set("valid_from", validFrom.toISOExtString())
     .set("valid_until", validUntil.toISOExtString());
  }
}

// ---------------------------------------------------------------------------
// SLMOperationLog – audit/monitoring log for solution operations
// ---------------------------------------------------------------------------
struct SLMOperationLog {
  UUID tenantId;
  string logId;
  string solutionId;
  string deploymentId;
  /// Action: "deployed" | "updated" | "deleted" | "subscribed" | "unsubscribed" |
  ///         "component-started" | "component-stopped" | "error"
  string action;
  string message;
  /// Level: "info" | "warning" | "error"
  string level;
  SysTime timestamp;

  Json toJson() {
    Json j = Json.emptyObject;
    j["tenant_id"] = tenantId;
    j["log_id"] = logId;
    j["solution_id"] = solutionId;
    j["deployment_id"] = deploymentId;
    j["action"] = action;
    j["message"] = message;
    j["level"] = level;
    j["timestamp"] = timestamp.toISOExtString();
    return j;
  }
}
