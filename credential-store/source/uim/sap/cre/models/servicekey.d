module uim.sap.cre.models.servicekey;

import uim.sap.cre;

mixin(ShowModule!());

@safe:

class CREServiceKey : SAPEntity {
  mixin(SAPEntityTemplate!CREServiceKey);

  UUID instanceId;
  UUID keyId;
  CREEncryptedPayload secret;
  Json parameters;
  SysTime createdAt;

  override Json toJson() {
    return super.toJson()
      .set("instance_id", instanceId.toString())
      .set("service_key_id", keyId)
      .set("algorithm", secret.algorithm)
      .set("parameters", parameters);
  }

  static CREServiceKey opCall(UUID instanceId, UUID keyId, Json request, CREEncryptedPayload encrypted) {
    CREServiceKey key;
    key.instanceId = instanceId;
    key.keyId = keyId;
    key.secret = encrypted;
    key.createdAt = Clock.currTime();

    key.parameters = "parameters" in request && request["parameters"].isObject 
    ? request["parameters"] : Json.emptyObject;

    return key;

  }
}
