module uim.sap.cre.models.servicekey;

import std.datetime : Clock, SysTime;
import std.string : replace;
import std.uuid : randomUUID;

import vibe.data.json : Json;

struct CREServiceKey {
  string instanceId;
  string keyId;
  CREEncryptedPayload secret;
  Json parameters;
  SysTime createdAt;

  Json toJsonSummary() const {
    Json payload = Json.emptyObject;
    payload["instance_id"] = instanceId;
    payload["service_key_id"] = keyId;
    payload["algorithm"] = secret.algorithm;
    payload["created_at"] = createdAt.toISOExtString();
    payload["parameters"] = parameters;
    return payload;
  }
}

CREServiceKey serviceKeyFromJson(string instanceId, string keyId, Json request, CREEncryptedPayload encrypted) {
  CREServiceKey key;
  key.instanceId = instanceId;
  key.keyId = keyId;
  key.secret = encrypted;
  key.createdAt = Clock.currTime();

  if ("parameters" in request && request["parameters"].type == Json.Type.object) {
    key.parameters = request["parameters"];
  } else {
    key.parameters = Json.emptyObject;
  }
  return key;
}

