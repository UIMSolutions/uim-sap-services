module uim.sap.cre.service;

import std.datetime : Clock;

import vibe.data.json : Json, parseJsonString;

import uim.sap.cre.config;
import uim.sap.cre.crypto;
import uim.sap.cre.exceptions;
import uim.sap.cre.models;
import uim.sap.cre.store;

/**
  * Main service class for the Credential Store.
  * Handles business logic and interactions with the store.
  *
  * Responsibilities:
  * - Validate input and service configuration
  * - Manage service instances and credentials
  * - Handle encryption and decryption of credentials
  * - Provide health and readiness checks
  * - Ensure proper error handling and response formatting
  *
  * The CREServer class will use this service to process incoming HTTP requests.
  *
  * Example usage:
  * CREConfig config = CREConfig(
  *     host: "localhost",
  *     port: 8080,
  *     serviceName: "Credential Store",
  *     serviceVersion: "1.0.0",
  *     authToken: "your-auth-token"
  * );
  * CREService service = new CREService(config);
  * service.run();
  *
  * Note: The actual running of the service is handled by the CREServer class, which will call the appropriate methods on this service based on incoming HTTP requests.
  * The service methods will return JSON payloads that the server can use to construct HTTP responses.
  * 
  * Fields:
  * - CREConfig _config: Configuration settings for the service, including host, port, service name, version, authentication token, and custom headers.
  * - CREStore _store: An instance of the CREStore class that manages the storage and retrieval of service instances, credentials, and service keys.
  *
  * Methods: 
  * - health(): Returns a JSON object indicating the health status of the service.
  * - ready(): Returns a JSON object indicating the readiness status of the service.
  * - upsertServiceInstance(instanceId, request): Creates or updates a service instance based on the provided instance ID and request data.
  * - listServiceInstances(): Returns a list of all service instances in JSON format.
  * - getServiceInstance(instanceId): Retrieves details of a specific service instance by its ID.
  * - deleteServiceInstance(instanceId): Deletes a specific service instance by its ID.
  * - upsertCredential(instanceId, credentialName, request, requestKey): Creates or updates a credential for a specific service instance.
  * - listCredentials(instanceId): Returns a list of all credentials for a specific service instance.
  * - getCredential(instanceId, credentialName, requestKey): Retrieves details of a specific credential for a service instance.
  * - deleteCredential(instanceId, credentialName): Deletes a specific credential for a service instance.
  * - upsertServiceKey(instanceId, serviceKeyId, request, requestKey): Creates or updates a service key for a specific service instance.
  * - getServiceKey(instanceId, serviceKeyId, requestKey): Retrieves details of a specific service key for a service instance.
  * - deleteServiceKey(instanceId, serviceKeyId): Deletes a specific service key for a service instance.
  */
class CREService : SAPService {
  private CREConfig _config;
  private CREStore _store;

  this(CREConfig config) {
    config.validate();
    _config = config;
    _store = new CREStore;
  }

  @property const(CREConfig) config() const {
    return _config;
  }

  Json health() {
    Json payload = Json.emptyObject;
    payload["ok"] = true;
    payload["serviceName"] = _config.serviceName;
    payload["serviceVersion"] = _config.serviceVersion;
    return payload;
  }

  Json ready() {
    Json payload = Json.emptyObject;
    payload["ready"] = true;
    return payload;
  }

  Json upsertServiceInstance(string instanceId, Json request) {
    auto instance = instanceFromJson(instanceId, request);
    if (instance.serviceId.length == 0) {
      throw new CREValidationException("service_id is required");
    }
    if (instance.planId.length == 0) {
      throw new CREValidationException("plan_id is required");
    }
    instance.updatedAt = Clock.currTime();
    auto saved = _store.upsertInstance(instance);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["instance"] = saved.toJson();
    return payload;
  }

  Json listServiceInstances() {
    Json payload = Json.emptyObject;
    Json resources = Json.emptyArray;
    foreach (item; _store.listInstances()) {
      resources ~= item.toJson();
    }
    payload["resources"] = resources;
    payload["total_results"] = cast(long)_store.listInstances().length;
    return payload;
  }

  Json getServiceInstance(string instanceId) {
    auto instance = _store.getInstance(instanceId);
    if (instance.instanceId.length == 0) {
      throw new CRENotFoundException("Service instance", instanceId);
    }
    Json payload = Json.emptyObject;
    payload["instance"] = instance.toJson();
    return payload;
  }

  Json deleteServiceInstance(string instanceId) {
    if (!_store.deleteInstance(instanceId)) {
      throw new CRENotFoundException("Service instance", instanceId);
    }
    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["message"] = "Service instance deleted";
    payload["instance_id"] = instanceId;
    return payload;
  }

  Json upsertCredential(string instanceId, string credentialName, Json request, string requestKey) {
    validateInstance(instanceId);
    if (!("credential" in request) || !request["credential"].isString) {
      throw new CREValidationException("credential (string) is required");
    }

    auto encryptionKey = resolveEncryptionKey(request, requestKey);
    auto encrypted = encryptString(request["credential"].get!string, encryptionKey);
    auto credential = credentialFromJson(instanceId, credentialName, request, encrypted);
    credential.updatedAt = Clock.currTime();

    auto saved = _store.upsertCredential(credential);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["credential"] = saved.toJsonSummary();
    return payload;
  }

  Json listCredentials(string instanceId) {
    validateInstance(instanceId);
    Json payload = Json.emptyObject;
    Json resources = Json.emptyArray;
    foreach (credential; _store.listCredentials(instanceId)) {
      resources ~= credential.toJsonSummary();
    }
    payload["resources"] = resources;
    payload["total_results"] = cast(long)_store.listCredentials(instanceId).length;
    return payload;
  }

  Json getCredential(string instanceId, string credentialName, string requestKey) {
    validateInstance(instanceId);
    auto credential = _store.getCredential(instanceId, credentialName);
    if (credential.name.length == 0) {
      throw new CRENotFoundException("Credential", credentialName);
    }

    auto key = requestKey.length > 0 ? requestKey : _config.masterKey;
    string plaintext;
    try {
      plaintext = decryptString(credential.secret, key);
    } catch (Exception) {
      throw new CREValidationException("Unable to decrypt credential with provided key");
    }

    Json payload = Json.emptyObject;
    payload["instance_id"] = instanceId;
    payload["name"] = credentialName;
    payload["credential"] = plaintext;
    payload["metadata"] = credential.metadata;
    payload["updated_at"] = credential.updatedAt.toISOExtString();
    return payload;
  }

  Json deleteCredential(string instanceId, string credentialName) {
    validateInstance(instanceId);
    if (!_store.deleteCredential(instanceId, credentialName)) {
      throw new CRENotFoundException("Credential", credentialName);
    }
    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["message"] = "Credential deleted";
    payload["instance_id"] = instanceId;
    payload["name"] = credentialName;
    return payload;
  }

  Json upsertServiceKey(string instanceId, string serviceKeyId, Json request, string requestKey) {
    validateInstance(instanceId);

    Json keyPayload = Json.emptyObject;
    keyPayload["instance_id"] = instanceId;
    keyPayload["service_key_id"] = serviceKeyId;
    keyPayload["clientid"] = "sk-" ~ serviceKeyId;
    keyPayload["clientsecret"] = generateSecretToken();
    keyPayload["url"] = _config.basePath ~ "/v1/service_instances/" ~ instanceId ~ "/credentials";

    auto keyText = keyPayload.toString();
    auto encryptionKey = resolveEncryptionKey(request, requestKey);
    auto encrypted = encryptString(keyText, encryptionKey);

    auto serviceKey = serviceKeyFromJson(instanceId, serviceKeyId, request, encrypted);
    auto saved = _store.upsertServiceKey(serviceKey);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["service_key"] = saved.toJsonSummary();
    return payload;
  }

  Json getServiceKey(string instanceId, string serviceKeyId, string requestKey) {
    validateInstance(instanceId);
    auto serviceKey = _store.getServiceKey(instanceId, serviceKeyId);
    if (serviceKey.keyId.length == 0) {
      throw new CRENotFoundException("Service key", serviceKeyId);
    }

    auto key = requestKey.length > 0 ? requestKey : _config.masterKey;
    string plaintext;
    try {
      plaintext = decryptString(serviceKey.secret, key);
    } catch (Exception) {
      throw new CREValidationException("Unable to decrypt service key with provided key");
    }

    Json payload = Json.emptyObject;
    payload["instance_id"] = instanceId;
    payload["service_key_id"] = serviceKeyId;
    payload["credentials"] = parseJsonString(plaintext);
    payload["created_at"] = serviceKey.createdAt.toISOExtString();
    return payload;
  }

  Json deleteServiceKey(string instanceId, string serviceKeyId) {
    validateInstance(instanceId);
    if (!_store.deleteServiceKey(instanceId, serviceKeyId)) {
      throw new CRENotFoundException("Service key", serviceKeyId);
    }
    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["message"] = "Service key deleted";
    payload["instance_id"] = instanceId;
    payload["service_key_id"] = serviceKeyId;
    return payload;
  }

  private void validateInstance(string instanceId) {
    if (!_store.hasInstance(instanceId)) {
      throw new CRENotFoundException("Service instance", instanceId);
    }
  }

  private string resolveEncryptionKey(Json request, string requestKey) {
    if ("encryption_key" in request && request["encryption_key"].isString) {
      auto bodyKey = request["encryption_key"].get!string;
      if (bodyKey.length > 0) {
        return bodyKey;
      }
    }
    if (requestKey.length > 0) {
      return requestKey;
    }
    return _config.masterKey;
  }
}
