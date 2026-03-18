module uim.sap.cid.models.repository;
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