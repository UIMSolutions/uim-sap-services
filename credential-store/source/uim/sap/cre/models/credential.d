module uim.sap.cre.models.credential;

import uim.sap.cre;

mixin(ShowModule!());

@safe:

class CRECredential : SAPObject {
  mixin(SAPObjectTemplate!CRECredential);

  UUID instanceId;
  string name;
  CREEncryptedPayload secret;
  Json metadata;
  
  override Json toJson() {
    return toJson()
      .set("name", name)
      .set("instance_id", instanceId.toString())
      .set("algorithm", secret.algorithm)
      .set("metadata", metadata);
  }
}

CRECredential credentialFromJson(UUID instanceId, string credentialName, Json request, CREEncryptedPayload encrypted) {
  CRECredential credential;
  credential.instanceId = instanceId;
  credential.name = credentialName;
  credential.secret = encrypted;
  credential.createdAt = Clock.currTime();
  credential.updatedAt = credential.createdAt;

  credential.metadata = "metadata" in request && request["metadata"].isObject
    ? request["metadata"]
    : Json.emptyObject;

  return credential;
}
