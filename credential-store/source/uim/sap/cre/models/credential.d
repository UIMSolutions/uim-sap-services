module uim.sap.cre.models.credential;

import uim.sap.cre;

mixin(ShowModule!());

@safe:

struct CRECredential {
  UUID instanceId;
  string name;
  CREEncryptedPayload secret;
  Json metadata;
  SysTime createdAt;
  SysTime updatedAt;

  Json toJsonSummary() const {
    Json payload = Json.emptyObject;
    payload["instance_id"] = instanceId;
    payload["name"] = name;
    payload["algorithm"] = secret.algorithm;
    payload["created_at"] = createdAt.toISOExtString();
    payload["updated_at"] = updatedAt.toISOExtString();
    payload["metadata"] = metadata;
    return payload;
  }
}

CRECredential credentialFromJson(string instanceId, string credentialName, Json request, CREEncryptedPayload encrypted) {
  CRECredential credential;
  credential.instanceId = instanceId;
  credential.name = credentialName;
  credential.secret = encrypted;
  credential.createdAt = Clock.currTime();
  credential.updatedAt = credential.createdAt;

  if ("metadata" in request && request["metadata"].isObject) {
    credential.metadata = request["metadata"];
  } else {
    credential.metadata = Json.emptyObject;
  }
  return credential;
}
