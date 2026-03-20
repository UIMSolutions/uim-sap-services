module uim.sap.slm.models.models;

import uim.sap.slm;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// SLMSolution – a deployed solution in a subaccount
// ---------------------------------------------------------------------------
struct SLMSolution {
    UUID tenantId;
    string solutionId;
    string name;
    string description;
    /// MTA ID of the deployed Multi-Target Application
    string mtaId;
    /// Current version string
    string mtaVersion;
    /// Status: "deploying" | "deployed" | "updating" | "error" | "deleting" | "deleted"
    string status;
    /// Global account and subaccount identifiers
    string globalAccountId;
    string subaccountId;
    /// Space / org in Cloud Foundry
    string spaceId;
    string orgId;
    /// Whether this solution is multitenant
    bool multitenant;
    /// The user who deployed the solution
    string deployedBy;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() {
        Json j = Json.emptyObject;
        j["tenant_id"]          = tenantId;
        j["solution_id"]        = solutionId;
        j["name"]               = name;
        j["description"]        = description;
        j["mta_id"]             = mtaId;
        j["mta_version"]        = mtaVersion;
        j["status"]             = status;
        j["global_account_id"]  = globalAccountId;
        j["subaccount_id"]      = subaccountId;
        j["space_id"]           = spaceId;
        j["org_id"]             = orgId;
        j["multitenant"]        = multitenant;
        j["deployed_by"]        = deployedBy;
        j["created_at"]         = createdAt.toISOExtString();
        j["updated_at"]         = updatedAt.toISOExtString();
        return j;
    }
}

// ---------------------------------------------------------------------------
// SLMComponent – an individual component of a deployed solution
// ---------------------------------------------------------------------------
struct SLMComponent {
    string solutionId;
    string componentId;
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
        Json j = Json.emptyObject;
        j["solution_id"]    = solutionId;
        j["component_id"]   = componentId;
        j["name"]           = name;
        j["component_type"] = componentType;
        j["status"]         = status;
        j["url"]            = url;
        j["memory_mb"]      = memoryMb;
        j["instances"]      = instances;
        j["created_at"]     = createdAt.toISOExtString();
        j["updated_at"]     = updatedAt.toISOExtString();
        return j;
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
        j["tenant_id"]       = tenantId;
        j["deployment_id"]   = deploymentId;
        j["solution_id"]     = solutionId;
        j["mta_archive_ref"] = mtaArchiveRef;
        j["mta_version"]     = mtaVersion;
        j["action"]          = action;
        j["status"]          = status;
        j["triggered_by"]    = triggeredBy;
        j["error_message"]   = errorMessage;
        j["started_at"]      = startedAt.toISOExtString();
        j["finished_at"]     = finishedAt.toISOExtString();
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
        j["tenant_id"]               = tenantId;
        j["subscription_id"]         = subscriptionId;
        j["solution_id"]             = solutionId;
        j["consumer_subaccount_id"]  = consumerSubaccountId;
        j["consumer_tenant_id"]      = consumerTenantId;
        j["status"]                  = status;
        j["entitlement_id"]          = entitlementId;
        j["subscribed_by"]           = subscribedBy;
        j["subscribed_at"]           = subscribedAt.toISOExtString();
        j["unsubscribed_at"]         = unsubscribedAt.toISOExtString();
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
    string status;  // "active" | "expired" | "suspended"
    SysTime validFrom;
    SysTime validUntil;

    Json toJson() {
        Json j = Json.emptyObject;
        j["tenant_id"]    = tenantId;
        j["license_id"]   = licenseId;
        j["solution_id"]  = solutionId;
        j["plan"]         = plan;
        j["quota_limit"]  = quotaLimit;
        j["quota_used"]   = quotaUsed;
        j["status"]       = status;
        j["valid_from"]   = validFrom.toISOExtString();
        j["valid_until"]  = validUntil.toISOExtString();
        return j;
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
        j["tenant_id"]     = tenantId;
        j["log_id"]        = logId;
        j["solution_id"]   = solutionId;
        j["deployment_id"] = deploymentId;
        j["action"]        = action;
        j["message"]       = message;
        j["level"]         = level;
        j["timestamp"]     = timestamp.toISOExtString();
        return j;
    }
}
