module uim.sap.cid.models.credential;
import uim.sap.cid;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// CIDCredential – a stored credential for private repositories
// ---------------------------------------------------------------------------
class CIDCredential : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!CIDCredential);

  UUID credentialId;
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

  override Json toJson() {
    return super.toJson()
      .set("credential_id", credentialId)
      .set("name", name)
      .set("description", description)
      .set("credential_type", credentialType)
      .set("username", username)
      .set("token", token.length > 0 ? "***" : "") // Never expose secrets in JSON
      .set("ssh_key", sshKey.length > 0 ? "***" : "");
  }
}
