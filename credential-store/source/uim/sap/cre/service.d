module uim.sap.cre.service;

import uim.sap.cre;

mixin(ShowModule!());

@safe:

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
  mixin(SAPServiceTemplate!CREService);

  private CREStore _store;

  this(CREConfig config) {
    super(config);

    _store = new CREStore;
  }

  Json upsertServiceInstance(UUID instanceId, Json request) {
    CREServiceInstance instance = CREServiceInstance(instanceId, request);

    if (instance.serviceId.isNull == 0) {
      throw new CREValidationException("service_id is required");
    }

    if (instance.isNull) {
      throw new CREValidationException("plan_id is required");
    }

    instance.updatedAt = Clock.currTime();
    auto saved = _store.upsertInstance(instance);

    return Json.emptyObject
      .set("success", true)
      .set("instance", saved.toJson());
  }

  Json listServiceInstances() {
    Json resources = _store.listInstances().map!(item => item.toJson()).array.toJson();

    return Json.emptyObject
      .set("resources", resources)
      .set("total_results", cast(long)_store.listInstances().length);
  }

  Json getServiceInstance(UUID instanceId) {
    auto instance = _store.getInstance(instanceId);
    if (instance.instanceId.toString.length == 0) {
      throw new CRENotFoundException("Service instance", instanceId.toString);
    }

    return Json.emptyObject
      .set("instance", instance.toJson());
  }

  Json deleteServiceInstance(UUID instanceId) {
    if (!_store.deleteInstance(instanceId)) {
      throw new CRENotFoundException("Service instance", instanceId.toString);
    }

    return Json.emptyObject
      .set("success", true)
      .set("message", "Service instance deleted")
      .set("instance_id", instanceId.toString);
  }

  Json upsertCredential(UUID instanceId, string credentialName, Json request, string requestKey) {
    validateInstance(instanceId);
    if (!("credential" in request) || !request["credential"].isString) {
      throw new CREValidationException("credential (string) is required");
    }

    auto encryptionKey = resolveEncryptionKey(request, requestKey);
    auto encrypted = encryptString(request["credential"].get!string, encryptionKey);
    auto credential = credentialFromJson(instanceId, credentialName, request, encrypted);
    credential.updatedAt = Clock.currTime();

    auto saved = _store.upsertCredential(credential);

    return Json.emptyObject
      .set("success", true)
      .set("credential", saved.toJsonSummary());
  }

  Json listCredentials(UUID instanceId) {
    validateInstance(instanceId);
    Json resources = _store.listCredentials(instanceId)
      .map!(credential => credential.toJsonSummary()).array.toJson();

    return Json.emptyObject
      .set("resources", resources)
      .set("total_results", cast(long)_store.listCredentials(instanceId).length);
  }

  Json getCredential(UUID instanceId, string credentialName, string requestKey) {
    validateInstance(instanceId);
    auto credential = _store.getCredential(instanceId, credentialName);
    if (credential.name.length == 0) {
      throw new CRENotFoundException("Credential", credentialName);
    }

    auto key = requestKey.length > 0 ? requestKey : (cast(CREConfig)_config).masterKey;
    string plaintext;
    try {
      plaintext = decryptString(credential.secret, key);
    } catch (Exception) {
      throw new CREValidationException("Unable to decrypt credential with provided key");
    }

    return Json.emptyObject
      .set("instance_id", instanceId.toString)
      .set("name", credentialName)
      .set("credential", plaintext)
      .set("metadata", credential.metadata)
      .set("updated_at", credential.updatedAt.toISOExtString());
  }

  Json deleteCredential(UUID instanceId, string credentialName) {
    validateInstance(instanceId);
    if (!_store.deleteCredential(instanceId, credentialName)) {
      throw new CRENotFoundException("Credential", credentialName);
    }

    return Json.emptyObject
      .set("success", true)
      .set("message", "Credential deleted")
      .set("instance_id", instanceId.toString)
      .set("name", credentialName);
  }

  Json upsertServiceKey(UUID instanceId, UUID serviceKeyId, Json request, string requestKey) {
    validateInstance(instanceId);

    Json keyPayload = Json.emptyObject
      .set("instance_id", instanceId.toString)
      .set("service_key_id", serviceKeyId.toString)
      .set("clientid", "sk-" ~ serviceKeyId.toString)
      .set("clientsecret", generateSecretToken())
      .set("url", _config.basePath ~ "/v1/service_instances/" ~ instanceId.toString ~ "/credentials");

    auto keyText = keyPayload.toString();
    auto encryptionKey = resolveEncryptionKey(request, requestKey);
    auto encrypted = encryptString(keyText, encryptionKey);

    auto serviceKey = CREServiceKey(instanceId, serviceKeyId, request, encrypted);
    auto saved = _store.upsertServiceKey(serviceKey);

    return Json.emptyObject
      .set("success", true)
      .set("service_key", saved.toJsonSummary());
  }

  Json getServiceKey(UUID instanceId, UUID serviceKeyId, string requestKey) {
    validateInstance(instanceId);
    auto serviceKey = _store.getServiceKey(instanceId, serviceKeyId);
    if (serviceKey.keyId.length == 0) {
      throw new CRENotFoundException("Service key", serviceKeyId.toString);
    }

    auto key = requestKey.length > 0 ? requestKey : (cast(CREConfig)_config).masterKey;
    string plaintext;
    try {
      plaintext = decryptString(serviceKey.secret, key);
    } catch (Exception) {
      throw new CREValidationException("Unable to decrypt service key with provided key");
    }

    return Json.emptyObject
      .set("instance_id", instanceId.toString)
      .set("service_key_id", serviceKeyId.toString)
      .set("credentials", parseJsonString(plaintext))
      .set("created_at", serviceKey.createdAt.toISOExtString());
  }

  Json deleteServiceKey(UUID instanceId, UUID serviceKeyId) {
    validateInstance(instanceId);
    if (!_store.deleteServiceKey(instanceId, serviceKeyId)) {
      throw new CRENotFoundException("Service key", serviceKeyId.toString);
    }

    return Json.emptyObject
      .set("success", true)
      .set("message", "Service key deleted")
      .set("instance_id", instanceId.toString)
      .set("service_key_id", serviceKeyId.toString);
  }

  private void validateInstance(UUID instanceId) {
    if (!_store.hasInstance(instanceId)) {
      throw new CRENotFoundException("Service instance", instanceId.toString);
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

    return (cast(CREConfig)_config).masterKey;
  }
}