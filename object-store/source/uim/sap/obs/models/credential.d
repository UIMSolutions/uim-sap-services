module uim.sap.obs.models.credential;

import std.datetime : Clock, SysTime;

import vibe.data.json : Json;

import uim.sap.obs.enumerations;

@safe:

/// Secure access credentials for a bucket
struct OBSCredential {
    string credentialId;
    string bucketId;
    string accessKeyId;
    string secretAccessKey;
    OBSCredentialStatus status = OBSCredentialStatus.active;
    OBSProvider provider;
    string region;
    string endpoint;        // provider-specific endpoint URL
    string description;
    SysTime issuedAt;
    SysTime expiresAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["credential_id"] = credentialId;
        j["bucket_id"] = bucketId;
        j["access_key_id"] = accessKeyId;
        // Never expose secretAccessKey in list responses
        j["status"] = cast(string) status;
        j["provider"] = cast(string) provider;
        j["region"] = region;
        j["endpoint"] = endpoint;
        j["description"] = description;
        j["issued_at"] = issuedAt.toISOExtString();
        j["expires_at"] = expiresAt.toISOExtString();
        return j;
    }

    Json toJsonWithSecret() const {
        Json j = toJson();
        j["secret_access_key"] = secretAccessKey;
        return j;
    }
}
