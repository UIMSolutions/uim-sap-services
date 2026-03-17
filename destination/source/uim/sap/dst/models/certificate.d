/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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

    override Json toJson()  {
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