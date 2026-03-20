module uim.sap.cre.models.servicekey;

import uim.sap.cre;

mixin(ShowModule!());

@safe:

class CREServiceKey : SAPObject {
  mixin(SAPObjectTemplate!CREServiceKey);

  UUID instanceId;
  string keyId;
  CREEncryptedPayload secret;
  Json parameters;
  SysTime createdAt;

  override Json toJson() const {
    return super.toJson()
      .set("instance_id", instanceId)
      .set("service_key_id", keyId)
      .set("algorithm", secret.algorithm)
      .set("parameters", parameters);
  }
}

CREServiceKey serviceKeyFromJson(UUID instanceId, string keyId, Json request, CREEncryptedPayload encrypted) {
  CREServiceKey key;
  key.instanceId = instanceId;
  key.keyId = keyId;
  key.secret = encrypted;
  key.createdAt = Clock.currTime();

  if ("parameters" in request && request["parameters"].isObject) {
    key.parameters = request["parameters"];
  } else {
    key.parameters = Json.emptyObject;
  }
  return key;
}

