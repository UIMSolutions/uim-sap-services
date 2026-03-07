module uim.sap.dst.models.certificate;

import uim.sap.dst;

mixin(ShowModule!());

@safe:
// ---------------------------------------------------------------------------
// DSTCertificate – a TLS certificate stored per tenant
// ---------------------------------------------------------------------------
struct DSTCertificate {
    string tenantId;
    /// Unique certificate name within a tenant
    string name;
    string description;
    /// Certificate type: "PEM" | "PFX" | "P12" | "JKS"
    string certType;
    /// Base64-encoded certificate content (stored but masked in output)
    string content;
    /// Issuer / subject hints
    string issuer;
    string subject;
    /// Expiry date as ISO string
    string expiresAt;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"]   = tenantId;
        j["name"]        = name;
        j["description"] = description;
        j["cert_type"]   = certType;
        j["content"]     = content.length > 0 ? "***" : "";
        j["issuer"]      = issuer;
        j["subject"]     = subject;
        j["expires_at"]  = expiresAt;
        j["created_at"]  = createdAt.toISOExtString();
        j["updated_at"]  = updatedAt.toISOExtString();
        return j;
    }
}