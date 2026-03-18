/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.obs.models.credential;

import std.datetime : Clock, SysTime;

import vibe.data.json : Json;

import uim.sap.obs.enumerations;

@safe:

/// Secure credentials to access a bucket
struct OBSCredential {
  string credentialId;
  string bucketId;
  string tenantId;
  OBSCredentialType credType = OBSCredentialType.accessKey;
  OBSProvider provider;
  string accessKeyId;
  string secretAccessKey;
  string sessionToken; // temporary STS token
  string endpoint; // provider endpoint URL
  string region;
  SysTime issuedAt;
  SysTime expiresAt;

  override Json toJson()  {
    Json json = super.toJson;
    .set("credential_id", credentialId)
    .set("bucket_id", bucketId)
    .set("tenant_id", tenantId)
    .set("credential_type", cast(string)credType)
    .set("provider", cast(string)provider)
    .set("access_key_id", accessKeyId)
    .set("secret_access_key", secretAccessKey)
    .set("endpoint", endpoint)
    .set("region", region)
    .set("issued_at", issuedAt.toISOExtString())
    .set("expires_at", expiresAt.toISOExtString());

    return sessionToken.length > 0
      ? json.set("session_token", sessionToken) : json;
  }

  /// Redacted version for listing (no secrets)
  Json toRedactedJson() const {
    return Json.emptyObject
    .set("credential_id", credentialId)
    .set("bucket_id", bucketId)
    .set("tenant_id", tenantId)
    .set("credential_type", cast(string)credType)
    .set("provider", cast(string)provider)
    .set("access_key_id", accessKeyId)
    .set("secret_access_key", "***REDACTED***")
    .set("endpoint", endpoint)
    .set("region", region)
    .set("issued_at", issuedAt.toISOExtString())
    .set("expires_at", expiresAt.toISOExtString());
  }
}
