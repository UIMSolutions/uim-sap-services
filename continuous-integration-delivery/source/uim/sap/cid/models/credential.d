module uim.sap.cid.models.credential;
import uim.sap.cid;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// CIDCredential – a stored credential for private repositories
// ---------------------------------------------------------------------------
struct CIDCredential {
    UUID tenantId;
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
