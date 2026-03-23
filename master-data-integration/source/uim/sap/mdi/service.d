module uim.sap.mdi.service;

import uim.sap.mdi;

mixin(ShowModule!());

@safe:
class MDIService : SAPService {
  private MDIConfig _config;
  private MDIStore _store;

  this(MDIConfig config) {
    super(config);
    _store = new MDIStore;
  }

  override Json health() {
    return super.health()
    .set("ok", true)
    .set("serviceName", _config.serviceName)
    .set("serviceVersion", _config.serviceVersion);
  }


  Json upsertClient(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");
    auto client = clientFromJson(tenantId, request);
    if (client.name.length == 0)
      throw new MDIValidationException("name is required");
    auto saved = _store.upsertClient(client);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["client"] = saved.toJson();
    return payload;
  }

  Json listClients(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = _store.listClients(tenantId).map!(client => client.toJson).array();

    Json payload = Json.emptyObject;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)resources.length;
    return payload;
  }

  Json upsertFilter(UUID tenantId, string filterId, Json request) {
    validateId(tenantId, "Tenant ID");
    validateId(filterId, "Filter ID");

    MDIFilter filter = new MDIFilter(request);
    filter.tenantId = UUID(tenantId);
    filter.filterId = filterId;
    filter.objectType = _config.defaultObjectType;
    filter.conditions = Json.emptyArray;
    filter.active = true;
    filter.updatedAt = Clock.currTime();

    if ("object_type" in request && request["object_type"].isString)
      filter.objectType = toLower(request["object_type"].get!string);
    if ("conditions" in request && request["conditions"].isArray)
      filter.conditions = request["conditions"];
    if ("active" in request && request["active"].isBoolean)
      filter.active = request["active"].get!bool;

    if (!isAllowedObjectType(filter.objectType))
      throw new MDIValidationException("Unsupported object_type");

    auto saved = _store.upsertFilter(filter);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["filter"] = saved.toJson();
    payload["managed_by"] = "sap-business-data-orchestration-compatible";
    return payload;
  }

  Json listFilters(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = _store.listFilters(tenantId).map!(filter => filter.toJson).array();

    Json payload = Json.emptyObject;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)resources.length;
    return payload;
  }

  Json upsertExtension(UUID tenantId, string extensionId, Json request) {
    validateId(tenantId, "Tenant ID");
    validateId(extensionId, "Extension ID");

    MDIExtension extension = new MDIExtension(request);
    extension.tenantId = UUID(tenantId);
    extension.extensionId = extensionId;
    extension.objectType = _config.defaultObjectType;
    extension.fields = Json.emptyArray;
    extension.entities = Json.emptyArray;
    extension.updatedAt = Clock.currTime();

    if ("object_type" in request && request["object_type"].isString)
      extension.objectType = toLower(request["object_type"].get!string);
    if ("fields" in request && request["fields"].isArray)
      extension.fields = request["fields"];
    if ("entities" in request && request["entities"].isArray)
      extension.entities = request["entities"];

    if (!isAllowedObjectType(extension.objectType))
      throw new MDIValidationException("Unsupported object_type");

    auto saved = _store.upsertExtension(extension);

    return Json.emptyObject
    .set("success", true)
    .set("extension", saved.toJson())
    .set("extensibility", true);
  }

  Json listExtensions(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = _store.listExtensions(tenantId).map!(extension => extension.toJson).array();

    return Json.emptyObject
    .set("resources", resources)
    .set("total_results", cast(long)resources.length);
  }

  Json replicate(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    if (!("source_client_id" in request) || !request["source_client_id"].isString) {
      throw new MDIValidationException("source_client_id is required");
    }
    if (!("target_client_id" in request) || !request["target_client_id"].isString) {
      throw new MDIValidationException("target_client_id is required");
    }

    auto sourceClientId = request["source_client_id"].get!string;
    auto targetClientId = request["target_client_id"].get!string;

    auto source = _store.getClient(tenantId, sourceClientId);
    auto target = _store.getClient(tenantId, targetClientId);
    if (source.clientId.length == 0)
      throw new MDINotFoundException("Source client", sourceClientId);
    if (target.clientId.length == 0)
      throw new MDINotFoundException("Target client", targetClientId);

    MDIReplicationJob job;
    job.tenantId = UUID(tenantId);
    job.jobId = createId();
    job.sourceClientId = sourceClientId;
    job.targetClientId = targetClientId;
    job.objectType = _config.defaultObjectType;
    job.mode = "incremental";
    job.status = "completed";
    job.filterIds = Json.emptyArray;
    job.createdAt = Clock.currTime();
    job.updatedAt = job.createdAt;

    if ("object_type" in request && request["object_type"].isString)
      job.objectType = toLower(request["object_type"].get!string);
    if ("mode" in request && request["mode"].isString)
      job.mode = request["mode"].get!string;
    if ("filter_ids" in request && request["filter_ids"].isArray)
      job.filterIds = request["filter_ids"];

    if (!isAllowedObjectType(job.objectType))
      throw new MDIValidationException("Unsupported object_type");

    auto saved = _store.upsertJob(job);

    return Json.emptyObject
    .set("success", true)
    .set("replication", saved.toJson())
    .set("replicated_between", Json.emptyObject
      .set("source", source.toJson())
      .set("target", target.toJson())
    );

  }

  Json listReplications(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = _store.listJobs(tenantId).map!(job => job.toJson).array();

    return Json.emptyObject
    .set("resources", resources)
    .set("total_results", cast(long)resources.length);
  }
}
