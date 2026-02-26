module uim.sap.cre.models;

import std.datetime : Clock, SysTime;
import std.string : replace;
import std.uuid : randomUUID;

import vibe.data.json : Json;

struct CREEncryptedPayload {
    ubyte[] cipherBytes;
    ubyte[] nonceBytes;
    string algorithm = "XOR-KEYSTREAM-V1";
    ulong checksum;
}

struct CREServiceInstance {
    string instanceId;
    string serviceId;
    string planId;
    string status = "created";
    Json parameters;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["instance_id"] = instanceId;
        payload["service_id"] = serviceId;
        payload["plan_id"] = planId;
        payload["status"] = status;
        payload["created_at"] = createdAt.toISOExtString();
        payload["updated_at"] = updatedAt.toISOExtString();
        payload["parameters"] = parameters;
        return payload;
    }
}

struct CRECredential {
    string instanceId;
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

CREServiceInstance instanceFromJson(string instanceId, Json request) {
    CREServiceInstance instance;
    instance.instanceId = instanceId;
    instance.createdAt = Clock.currTime();
    instance.updatedAt = instance.createdAt;

    if ("service_id" in request && request["service_id"].type == Json.Type.string) {
        instance.serviceId = request["service_id"].get!string;
    }
    if ("plan_id" in request && request["plan_id"].type == Json.Type.string) {
        instance.planId = request["plan_id"].get!string;
    }
    if ("parameters" in request && request["parameters"].type == Json.Type.object) {
        instance.parameters = request["parameters"];
    } else {
        instance.parameters = Json.emptyObject;
    }
    return instance;
}

CRECredential credentialFromJson(string instanceId, string credentialName, Json request, CREEncryptedPayload encrypted) {
    CRECredential credential;
    credential.instanceId = instanceId;
    credential.name = credentialName;
    credential.secret = encrypted;
    credential.createdAt = Clock.currTime();
    credential.updatedAt = credential.createdAt;

    if ("metadata" in request && request["metadata"].type == Json.Type.object) {
        credential.metadata = request["metadata"];
    } else {
        credential.metadata = Json.emptyObject;
    }
    return credential;
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

string generateSecretToken() {
    return randomUUID().toString().replace("-", "");
}
