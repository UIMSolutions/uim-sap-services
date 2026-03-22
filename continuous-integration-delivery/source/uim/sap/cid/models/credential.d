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
        return super.toJson()
        .set("tenant_id", tenantId)
        .set("credential_id", credentialId)
        .set("name", name)
        .set("description", description)
        .set("credential_type", credentialType)
        .set("username", username)
        .set("token", token.length > 0 ? "***" : "") // Never expose secrets in JSON
        .set("ssh_key", sshKey.length > 0 ? "***" : "")
        .set("created_at", createdAt.toISOExtString())
        .set("updated_at", updatedAt.toISOExtString());
    }
}
