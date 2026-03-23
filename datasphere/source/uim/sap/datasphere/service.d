/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.datasphere.service;

import uim.sap.datasphere;

mixin(ShowModule!());

@safe:

/**
  * DSPService provides core functionalities for data modeling, integration, governance, and consumption.
  * It manages in-memory storage of data models, business models, connections, spaces, and other resources. The service includes methods for creating, listing, and managing these resources, as well as handling tenant administration and audit events. It serves as the main interface for the Datasphere application logic.
  * 
  * Note: This implementation uses in-memory storage for simplicity and demonstration purposes. In a production environment, it would be necessary to integrate with a persistent storage solution to ensure data durability and scalability.
  *
  * Example usage:
  * ```
  * DSPConfig config = new DSPConfig();
  * DSPService service = new DSPService(config);
  * Json healthResponse = service.health();
  * Json readyResponse = service.ready();
  * Json createModelResponse = service.createDataModel("tenant123", json!({"name": "Sales Model"}));
  * Json listModelsResponse = service.listDataModels("tenant123");
  * ``` 
  * The example usage demonstrates how to initialize the DatasphereService with a configuration, check the health and readiness of the service, create a new data model for a tenant, and list all data models for that tenant. Similar methods can be used for managing business models, connections, spaces, row policies, and other resources provided by the service.
  */

class DSPService : SAPService {
  mixin(SAPServiceTemplate!DSPService);

  private DSPStore _store;

  this(DSPConfig config) {
    super(config);
    _store = new DSPStore;
  }

  override Json health() {
    Json capabilities = [
      "data_modeling", "business_modeling", "data_integration", 
      "space_management", "administration", "data_protection_and_privacy", 
      "data_governance", "consumption"
    ].toJson;

    Json healthInfo = super.health();
    healthInfo["capabilities"] = capabilities;
    return healthInfo;
  }


  Json createDataModel(UUID tenantId, Json request) {
    validateTenant(tenantId);
    auto modelName = requiredString(request, "name");

    DATDataModel item;
    item.tenantId = tenantId;
    item.modelId = optionalString(request, "model_id", _store.nextId("dmodel"));
    item.name = modelName;
    item.modelType = optionalString(request, "model_type", "graphical");
    item.sqlDefinition = optionalString(request, "sql_definition", "");
    item.dataFlowDefinition = optionalString(request, "data_flow_definition", "");
    item.sources = stringArray(request, "sources");
    item.status = "active";
    item.updatedAt = Clock.currTime();

    auto saved = _store.upsertDataModel(item);

    return Json.emptyObject
      .set("success", true)
      .set("model", saved.toJson());
  }

  Json listDataModels(UUID tenantId) {
    validateTenant(tenantId);
    Json resources = Json.emptyArray;
    foreach (item; _store.listDataModels(tenantId))
      resources ~= item.toJson();

    Json payload = Json.emptyObject;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)resources.length;
    return payload;
  }

  Json createExternalDataset(UUID tenantId, Json request) {
    validateTenant(tenantId);
    auto sourceType = toLower(requiredString(request, "source_type"));
    if (sourceType != "csv" && sourceType != "marketplace" && sourceType != "third_party") {
      throw new DSPValidationException(
        "source_type must be csv, marketplace, or third_party");
    }

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["tenant_id"] = tenantId;
    payload["dataset_id"] = optionalString(request, "dataset_id", _store.nextId("dataset"));
    payload["source_type"] = sourceType;
    payload["status"] = "enriched";
    payload["note"] = "Dataset available for modeling and transformation.";
    return payload;
  }

  Json runDataFlow(UUID tenantId, Json request) {
    validateTenant(tenantId);
    auto name = requiredString(request, "name");

    return Json.emptyObject
      .set("success", true)
      .set("tenant_id", tenantId)
      .set("flow_id", optionalString(request, "flow_id", _store.nextId("flow")))
      .set("name", name)
      .set("status", "completed")
      .set("mode", optionalString(request, "mode", "transform"));
  }

  Json replicateModel(UUID tenantId, Json request) {
    validateTenant(tenantId);
    auto modelId = requiredString(request, "model_id");

    DATDataModel model;
    if (!_store.getDataModel(tenantId, modelId, model)) {
      throw new DSPNotFoundException("Data model", modelId);
    }

    model.status = "replicated";
    model.updatedAt = Clock.currTime();
    auto saved = _store.upsertDataModel(model);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["model"] = saved.toJson();
    payload["replication_status"] = "completed";
    return payload;
  }

  Json createBusinessModel(UUID tenantId, Json request) {
    validateTenant(tenantId);
    auto modelName = requiredString(request, "name");

    DATBusinessModel item;
    item.tenantId = tenantId;
    item.modelId = optionalString(request, "model_id", _store.nextId("bmodel"));
    item.name = modelName;
    item.description = optionalString(request, "description", "");
    item.grain = optionalString(request, "grain", "daily");
    item.dimensions = stringArray(request, "dimensions");
    item.measures = stringArray(request, "measures");
    item.updatedAt = Clock.currTime();

    auto saved = _store.upsertBusinessModel(item);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["model"] = saved.toJson();
    return payload;
  }

  Json listBusinessModels(UUID tenantId) {
    validateTenant(tenantId);
    Json resources = Json.emptyArray;
    foreach (item; _store.listBusinessModels(tenantId))
      resources ~= item.toJson();

    Json payload = Json.emptyObject;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)resources.length;
    return payload;
  }

  Json previewBusinessModel(UUID tenantId, string modelId) {
    validateTenant(tenantId);

    DATBusinessModel model;
    if (!_store.getBusinessModel(tenantId, modelId, model)) {
      throw new DSPNotFoundException("Business model", modelId);
    }

    Json sample = Json.emptyArray;
    Json rowA = Json.emptyObject;
    Json rowB = Json.emptyObject;

    foreach (dimension; model.dimensions) {
      rowA[dimension] = dimension ~ "-A";
      rowB[dimension] = dimension ~ "-B";
    }
    foreach (measure; model.measures) {
      rowA[measure] = 100;
      rowB[measure] = 250;
    }

    sample ~= rowA;
    sample ~= rowB;

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["model_id"] = modelId;
    payload["preview"] = sample;
    return payload;
  }

  Json createConnection(UUID tenantId, Json request) {
    validateTenant(tenantId);
    auto name = requiredString(request, "name");
    auto sourceType = requiredString(request, "source_type");
    auto mode = toLower(optionalString(request, "mode", "federate"));
    if (mode != "federate" && mode != "replicate" && mode != "transform_load") {
      throw new DSPValidationException("mode must be federate, replicate, or transform_load");
    }

    DATIntegrationConnection item;
    item.tenantId = tenantId;
    item.connectionId = optionalString(request, "connection_id", _store.nextId("conn"));
    item.name = name;
    item.sourceType = sourceType;
    item.mode = mode;
    item.secure = optionalBoolean("secure", true);
    item.status = "connected";
    item.updatedAt = Clock.currTime();

    auto saved = _store.upsertConnection(item);

    return Json.emptyObject
      .set("success", true)
      .set("connection", saved.toJson());
  }

  Json listConnections(UUID tenantId) {
    validateTenant(tenantId);
    Json resources = Json.emptyArray;
    foreach (item; _store.listConnections(tenantId))
      resources ~= item.toJson();

    Json payload = Json.emptyObject;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)resources.length;
    return payload;
  }

  Json migrateTrustedModels(UUID tenantId, Json request) {
    validateTenant(tenantId);
    auto sourceSystem = requiredString(request, "source_system");

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["tenant_id"] = tenantId;
    payload["source_system"] = sourceSystem;
    payload["migration_job_id"] = _store.nextId("migration");
    payload["status"] = "completed";
    return payload;
  }

  Json createSpace(UUID tenantId, Json request) {
    validateTenant(tenantId);

    DATSpace item;
    item.tenantId = tenantId;
    item.spaceId = optionalString(request, "space_id", _store.nextId("space"));
    item.name = requiredString(request, "name");
    item.diskGb = request.getInteger("disk_gb", _config.defaultSpaceDiskGb);
    item.memoryGb = request.getInteger("memory_gb", _config.defaultSpaceMemoryGb);
    item.priority = request.getInteger("priority", 5);
    item.users = stringArray(request, "users");
    item.active = true;
    item.updatedAt = Clock.currTime();

    auto saved = _store.upsertSpace(item);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["space"] = saved.toJson();
    return payload;
  }

  Json listSpaces(UUID tenantId) {
    validateTenant(tenantId);
    Json resources = Json.emptyArray;
    foreach (item; _store.listSpaces(tenantId))
      resources ~= item.toJson();

    Json payload = Json.emptyObject;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)resources.length;
    return payload;
  }

  Json updateSpace(UUID tenantId, string spaceId, Json request) {
    validateTenant(tenantId);
    validateId(spaceId, "Space ID");

    DATSpace item;
    if (!_store.getSpace(tenantId, spaceId, item)) {
      throw new DSPNotFoundException("Space", spaceId);
    }

    item.name = optionalString(request, "name", item.name);
    item.diskGb = request.getInteger("disk_gb", item.diskGb);
    item.memoryGb = request.getInteger("memory_gb", item.memoryGb);
    item.priority = request.getInteger("priority", item.priority);
    if ("users" in request)
      item.users = stringArray(request, "users");
    if ("active" in request && request["active"].isBoolean)
      item.active = request["active"].get!bool;
    item.updatedAt = Clock.currTime();

    auto saved = _store.upsertSpace(item);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["space"] = saved.toJson();
    return payload;
  }

  Json addSpaceUser(UUID tenantId, string spaceId, Json request) {
    validateTenant(tenantId);
    validateId(spaceId, "Space ID");

    auto user = requiredString(request, "user");

    DATSpace item;
    if (!_store.getSpace(tenantId, spaceId, item)) {
      throw new DSPNotFoundException("Space", spaceId);
    }

    if (!contains(item.users, user))
      item.users ~= user;
    item.updatedAt = Clock.currTime();
    auto saved = _store.upsertSpace(item);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["space"] = saved.toJson();
    return payload;
  }

  Json upsertTenantAdminState(Json request) {
    DATTenantAdminState state = _store.getTenantState();
    state.tenantName = optionalString(request, "tenant_name", state.tenantName);
    state.connectivityPrepared = optionalBoolean(request, "connectivity_prepared", state
        .connectivityPrepared);
    state.maintenanceMode = optionalBoolean(request, "maintenance_mode", state.maintenanceMode);
    state.lastMaintenance = optionalString(request, "last_maintenance", state.lastMaintenance);

    if ("users" in request)
      state.users = stringArray(request, "users");
    if ("custom" in request && request["custom"].isObject)
      state.custom = request["custom"];

    auto saved = _store.upsertTenantState(state);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["tenant"] = saved.toJson();
    return payload;
  }

  Json getTenantAdminState() {
    Json payload = Json.emptyObject;
    Json monitoring = Json.emptyArray;
    monitoring ~= "spaces";
    monitoring ~= "connections";
    monitoring ~= "audit";
    monitoring ~= "data_flows";

    payload["tenant"] = _store.getTenantState().toJson();
    payload["monitoring"] = monitoring;
    return payload;
  }

  Json upsertRowPolicy(UUID tenantId, string policyId, Json request) {
    validateTenant(tenantId);
    validateId(policyId, "Policy ID");

    DATRowPolicy item;
    item.tenantId = tenantId;
    item.policyId = policyId;
    item.dataset = requiredString(request, "dataset");
    item.expression = requiredString(request, "expression");
    item.updatedAt = Clock.currTime();

    auto saved = _store.upsertRowPolicy(item);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["policy"] = saved.toJson();
    return payload;
  }

  Json listRowPolicies(UUID tenantId) {
    validateTenant(tenantId);
    Json resources = Json.emptyArray;
    foreach (item; _store.listRowPolicies(tenantId))
      resources ~= item.toJson();

    Json payload = Json.emptyObject;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)resources.length;
    return payload;
  }

  Json setFunctionalAccess(UUID tenantId, string roleName, Json request) {
    validateTenant(tenantId);
    validateId(roleName, "Role name");

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["tenant_id"] = tenantId;
    payload["role"] = roleName;
    payload["functional_permissions"] = request;
    return payload;
  }

  Json setSpaceAccess(UUID tenantId, string spaceId, Json request) {
    validateTenant(tenantId);
    validateId(spaceId, "Space ID");

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["tenant_id"] = tenantId;
    payload["space_id"] = spaceId;
    payload["space_permissions"] = request;
    return payload;
  }

  Json addAuditEvent(UUID tenantId, Json request) {
    validateTenant(tenantId);

    DATAuditEvent item;
    item.tenantId = tenantId;
    item.eventId = optionalString(request, "event_id", _store.nextId("audit"));
    item.operation = requiredString(request, "operation");
    item.layer = optionalString(request, "layer", "data");
    item.actor = optionalString(request, "actor", "system");
    item.details = optionalString(request, "details", "");
    item.createdAt = Clock.currTime();

    auto saved = _store.addAuditEvent(item);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["event"] = saved.toJson();
    return payload;
  }

  Json listAuditEvents(UUID tenantId) {
    validateTenant(tenantId);
    Json resources = Json.emptyArray;
    foreach (item; _store.listAuditEvents(tenantId))
      resources ~= item.toJson();

    Json payload = Json.emptyObject;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)resources.length;
    return payload;
  }

  Json publishCatalogAsset(UUID tenantId, Json request) {
    validateTenant(tenantId);

    DATGovernanceAsset item;
    item.tenantId = tenantId;
    item.assetId = optionalString(request, "asset_id", _store.nextId("asset"));
    item.title = requiredString(request, "title");
    item.assetType = optionalString(request, "asset_type", "dataset");
    item.quality = optionalString(request, "quality", "trusted");
    item.published = true;
    item.updatedAt = Clock.currTime();

    auto saved = _store.upsertAsset(item);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["asset"] = saved.toJson();
    return payload;
  }

  Json listCatalogAssets(UUID tenantId) {
    validateTenant(tenantId);
    Json resources = Json.emptyArray;
    foreach (item; _store.listAssets(tenantId))
      resources ~= item.toJson();

    Json payload = Json.emptyObject;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)resources.length;
    return payload;
  }

  Json createGlossaryTerm(UUID tenantId, Json request) {
    validateTenant(tenantId);

    DATGlossaryTerm item;
    item.tenantId = tenantId;
    item.termId = optionalString(request, "term_id", _store.nextId("term"));
    item.term = requiredString(request, "term");
    item.definition = requiredString(request, "definition");
    item.updatedAt = Clock.currTime();

    auto saved = _store.upsertTerm(item);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["term"] = saved.toJson();
    return payload;
  }

  Json listGlossaryTerms(UUID tenantId) {
    validateTenant(tenantId);
    Json resources = Json.emptyArray;
    foreach (item; _store.listTerms(tenantId))
      resources ~= item.toJson();

    Json payload = Json.emptyObject;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)resources.length;
    return payload;
  }

  Json createKPI(UUID tenantId, Json request) {
    validateTenant(tenantId);

    DATKpi item;
    item.tenantId = tenantId;
    item.kpiId = optionalString(request, "kpi_id", _store.nextId("kpi"));
    item.name = requiredString(request, "name");
    item.formula = requiredString(request, "formula");
    item.unit = optionalString(request, "unit", "");
    item.updatedAt = Clock.currTime();

    auto saved = _store.upsertKPI(item);

    Json payload = Json.emptyObject;
    payload["success"] = true;
    payload["kpi"] = saved.toJson();
    return payload;
  }

  Json listKPIs(UUID tenantId) {
    validateTenant(tenantId);
    Json resources = Json.emptyArray;
    foreach (item; _store.listKPIs(tenantId))
      resources ~= item.toJson();

    Json payload = Json.emptyObject;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)resources.length;
    return payload;
  }

  Json listConsumptionConnectors(UUID tenantId) {
    validateTenant(tenantId);

    Json connectors = Json.emptyArray;

    Json sac = Json.emptyObject;
    sac["name"] = "Analytics Cloud";
    sac["type"] = "analytics";
    sac["status"] = "available";
    connectors ~= sac;

    Json excel = Json.emptyObject;
    excel["name"] = "Microsoft Excel";
    excel["type"] = "spreadsheet";
    excel["status"] = "available";
    connectors ~= excel;

    Json odata = Json.emptyObject;
    odata["name"] = "Public OData API";
    odata["type"] = "odata";
    odata["status"] = "available";
    connectors ~= odata;

    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["connectors"] = connectors;
    return payload;
  }

  Json odataEntity(UUID tenantId, string entitySet) {
    validateTenant(tenantId);
    validateId(entitySet, "Entity set");

    Json row = Json.emptyObject;
    row["ID"] = "row-1";
    row["EntitySet"] = entitySet;
    row["Tenant"] = tenantId;
    row["Value"] = 42;

    Json payload = Json.emptyObject;
    payload["@odata.context"] =
      _config.basePath ~
      "/v1/tenants/" ~
      tenantId ~
      "/consumption/odata/$metadata#" ~
      entitySet;
    payload["value"] = [row];
    return payload;
  }

  
}
