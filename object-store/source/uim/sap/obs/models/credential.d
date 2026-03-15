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
    Json j = Json.emptyObject;
    j["credential_id"] = credentialId;
    j["bucket_id"] = bucketId;
    j["tenant_id"] = tenantId;
    j["credential_type"] = cast(string)credType;
    j["provider"] = cast(string)provider;
    j["access_key_id"] = accessKeyId;
    j["secret_access_key"] = secretAccessKey;
    if (sessionToken.length > 0)
      j["session_token"] = sessionToken;
    j["endpoint"] = endpoint;
    j["region"] = region;
    j["issued_at"] = issuedAt.toISOExtString();
    j["expires_at"] = expiresAt.toISOExtString();
    return j;
  }

  /// Redacted version for listing (no secrets)
  Json toRedactedJson() const {
    Json j = Json.emptyObject;
    j["credential_id"] = credentialId;
    j["bucket_id"] = bucketId;
    j["tenant_id"] = tenantId;
    j["credential_type"] = cast(string)credType;
    j["provider"] = cast(string)provider;
    j["access_key_id"] = accessKeyId;
    j["secret_access_key"] = "***REDACTED***";
    j["endpoint"] = endpoint;
    j["region"] = region;
    j["issued_at"] = issuedAt.toISOExtString();
    j["expires_at"] = expiresAt.toISOExtString();
    return j;
  }
}
