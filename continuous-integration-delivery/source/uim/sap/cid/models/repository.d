module uim.sap.cid.models.repository;
import uim.sap.cid;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// CIDRepository – a connected Git repository
// ---------------------------------------------------------------------------
class CIDRepository : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!CIDRepository);

  UUID repoId;
  string name;
  string description;
  /// Full clone URL (HTTPS or SSH)
  string cloneUrl;
  /// Default branch to build from
  string defaultBranch;
  /// Optional reference to a stored credential
  UUID credentialId;
  /// Provider hint: "github" | "gitlab" | "bitbucket" | "other"
  string provider;
  /// Webhook secret for push events (optional)
  string webhookSecret;
  bool active;

  override Json toJson() {
    return super.toJson()
      .set("repo_id", repoId)
      .set("name", name)
      .set("description", description)
      .set("clone_url", cloneUrl)
      .set("default_branch", defaultBranch)
      .set("credential_id", credentialId)
      .set("provider", provider)
      .set("webhook_secret", webhookSecret.length > 0 ? "***" : "")
      .set("active", active);
  }
}
