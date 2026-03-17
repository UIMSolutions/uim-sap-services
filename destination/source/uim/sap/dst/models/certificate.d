/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.dst.models.certificate;

import uim.sap.dst;

mixin(ShowModule!());

@safe:

class DSTCertificate : SAPTenantObject {
  mixin(SAPObjectTemplate!DSTCertificate);

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

  override Json toJson()  {
    return super.toJson()
      .set("name", name)
      .set("description", description)
      .set("cert_type", certType)
      .set("content", content.length > 0 ? "***" : "")
      .set("issuer", issuer)
      .set("subject", subject)
      .set("expires_at", expiresAt);
  }
}