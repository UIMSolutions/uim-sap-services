module uim.sap.cid.models;

import uim.sap.cid;

mixin(ShowModule!());

@safe:
// ---------------------------------------------------------------------------
// CIDRepository – a connected Git repository
// ---------------------------------------------------------------------------
struct CIDRepository {
    string tenantId;
    string repoId;
    string name;
    string description;
    /// Full clone URL (HTTPS or SSH)
    string cloneUrl;
    /// Default branch to build from
    string defaultBranch;
    /// Optional reference to a stored credential
    string credentialId;
    /// Provider hint: "github" | "gitlab" | "bitbucket" | "other"
    string provider;
    /// Webhook secret for push events (optional)
    string webhookSecret;
    bool   active;
    SysTime createdAt;
    SysTime updatedAt;

    override Json toJson()  {
        Json j = Json.emptyObject;
        j["tenant_id"]      = tenantId;
        j["repo_id"]        = repoId;
        j["name"]           = name;
        j["description"]    = description;
        j["clone_url"]      = cloneUrl;
        j["default_branch"] = defaultBranch;
        j["credential_id"]  = credentialId;
        j["provider"]       = provider;
        j["webhook_secret"] = webhookSecret.length > 0 ? "***" : "";
        j["active"]         = active;
        j["created_at"]     = createdAt.toISOExtString();
        j["updated_at"]     = updatedAt.toISOExtString();
        return j;
    }
}

// ---------------------------------------------------------------------------
// CIDCredential – a stored credential for private repositories
// ---------------------------------------------------------------------------
struct CIDCredential {
    string tenantId;
    string credentialId;
    string name;
    string description;
    /// Type: "basic" | "token" | "ssh-key"
    string credentialType;
    /// Username (for basic auth)
    string username;
    /// Token or password (stored but masked in output)
    string token;
    /// SSH private key PEM (stored but masked in output)
    string sshKey;
    SysTime createdAt;
    SysTime updatedAt;

    override Json toJson()  {
        Json j = Json.emptyObject;
        j["tenant_id"]       = tenantId;
        j["credential_id"]   = credentialId;
        j["name"]            = name;
        j["description"]     = description;
        j["credential_type"] = credentialType;
        j["username"]        = username;
        // Never expose secrets in JSON
        j["token"]           = token.length > 0 ? "***" : "";
        j["ssh_key"]         = sshKey.length > 0 ? "***" : "";
        j["created_at"]      = createdAt.toISOExtString();
        j["updated_at"]      = updatedAt.toISOExtString();
        return j;
    }
}

// ---------------------------------------------------------------------------
// CIDPipeline – a CI/CD pipeline configuration
// ---------------------------------------------------------------------------
struct CIDPipeline {
    string tenantId;
    string pipelineId;
    string name;
    string description;
    /// Connected repository
    string repositoryId;
    /// Branch to build (overrides repo default if set)
    string branch;
    /// Pipeline type: "sap-cloud-sdk" | "sap-fiori" | "sap-integration" |
    ///                "sap-abap" | "custom"
    string pipelineType;
    /// Stages to run (e.g. ["build","test","deploy"])
    string[] stages;
    /// Deploy target runtime: "cloud-foundry" | "abap" | "neo" | "kyma"
    string deployTarget;
    /// Deploy endpoint / landscape URL
    string deployEndpoint;
    /// Credential for deploy (optional)
    string deployCredentialId;
    /// Whether the pipeline triggers automatically on push
    bool autoTrigger;
    bool active;
    SysTime createdAt;
    SysTime updatedAt;

    override Json toJson()  {
        Json j = Json.emptyObject;
        j["tenant_id"]            = tenantId;
        j["pipeline_id"]          = pipelineId;
        j["name"]                 = name;
        j["description"]          = description;
        j["repository_id"]        = repositoryId;
        j["branch"]               = branch;
        j["pipeline_type"]        = pipelineType;
        Json stArr = Json.emptyArray;
        foreach (s; stages) stArr ~= Json(s);
        j["stages"]               = stArr;
        j["deploy_target"]        = deployTarget;
        j["deploy_endpoint"]      = deployEndpoint;
        j["deploy_credential_id"] = deployCredentialId;
        j["auto_trigger"]         = autoTrigger;
        j["active"]               = active;
        j["created_at"]           = createdAt.toISOExtString();
        j["updated_at"]           = updatedAt.toISOExtString();
        return j;
    }
}

// ---------------------------------------------------------------------------
// CIDBuild – a single pipeline run / execution
// ---------------------------------------------------------------------------
struct CIDBuild {
    string tenantId;
    string buildId;
    string pipelineId;
    /// Build number (sequential per pipeline)
    int buildNumber;
    /// Git commit hash that triggered this build
    string commitHash;
    /// Branch being built
    string branch;
    /// Status: "pending" | "running" | "success" | "failure" | "aborted"
    string status;
    /// Who/what triggered the build
    string triggeredBy;
    /// Duration in seconds (filled after completion)
    long durationSecs;
    SysTime startedAt;
    SysTime finishedAt;
    SysTime createdAt;

    override Json toJson()  {
        Json j = Json.emptyObject;
        j["tenant_id"]     = tenantId;
        j["build_id"]      = buildId;
        j["pipeline_id"]   = pipelineId;
        j["build_number"]  = buildNumber;
        j["commit_hash"]   = commitHash;
        j["branch"]        = branch;
        j["status"]        = status;
        j["triggered_by"]  = triggeredBy;
        j["duration_secs"] = durationSecs;
        j["started_at"]    = startedAt.toISOExtString();
        j["finished_at"]   = finishedAt.toISOExtString();
        j["created_at"]    = createdAt.toISOExtString();
        return j;
    }
}

// ---------------------------------------------------------------------------
// CIDBuildStage – one stage within a build run
// ---------------------------------------------------------------------------
struct CIDBuildStage {
    string buildId;
    string stageId;
    /// Stage name: "build" | "test" | "deploy" | custom
    string name;
    /// Order within the build (1-based)
    int ordinal;
    /// Status: "pending" | "running" | "success" | "failure" | "skipped"
    string status;
    long durationSecs;
    SysTime startedAt;
    SysTime finishedAt;

    override Json toJson()  {
        Json j = Json.emptyObject;
        j["build_id"]      = buildId;
        j["stage_id"]      = stageId;
        j["name"]          = name;
        j["ordinal"]       = ordinal;
        j["status"]        = status;
        j["duration_secs"] = durationSecs;
        j["started_at"]    = startedAt.toISOExtString();
        j["finished_at"]   = finishedAt.toISOExtString();
        return j;
    }
}

// ---------------------------------------------------------------------------
// CIDBuildLog – a log entry produced during a build
// ---------------------------------------------------------------------------
struct CIDBuildLog {
    string tenantId;
    string logId;
    string buildId;
    /// Optional: stage this log belongs to
    string stageId;
    /// Level: "info" | "warning" | "error" | "debug"
    string level;
    string message;
    SysTime timestamp;

    override Json toJson()  {
        Json j = Json.emptyObject;
        j["tenant_id"] = tenantId;
        j["log_id"]    = logId;
        j["build_id"]  = buildId;
        j["stage_id"]  = stageId;
        j["level"]     = level;
        j["message"]   = message;
        j["timestamp"] = timestamp.toISOExtString();
        return j;
    }
}
