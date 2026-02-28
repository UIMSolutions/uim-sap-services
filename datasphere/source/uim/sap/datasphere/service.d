module uim.sap.datasphere.service;

import std.datetime : Clock;
import std.string : toLower;

import vibe.data.json : Json;

import uim.sap.datasphere.config;
import uim.sap.datasphere.exceptions;
import uim.sap.datasphere.models;
import uim.sap.datasphere.store;

class DatasphereService {
    private DatasphereConfig _config;
    private DatasphereStore _store;

    this(DatasphereConfig config) {
        config.validate();
        _config = config;
        _store = new DatasphereStore;
    }

    @property const(DatasphereConfig) config() const { return _config; }

    Json health() {
        Json payload = Json.emptyObject;
        Json capabilities = Json.emptyArray;
        capabilities ~= "data_modeling";
        capabilities ~= "business_modeling";
        capabilities ~= "data_integration";
        capabilities ~= "space_management";
        capabilities ~= "administration";
        capabilities ~= "data_protection_and_privacy";
        capabilities ~= "data_governance";
        capabilities ~= "consumption";

        payload["ok"] = true;
        payload["serviceName"] = _config.serviceName;
        payload["serviceVersion"] = _config.serviceVersion;
        payload["capabilities"] = capabilities;
        return payload;
    }

    Json ready() {
        Json payload = Json.emptyObject;
        payload["ready"] = true;
        payload["timestamp"] = Clock.currTime().toISOExtString();
        return payload;
    }

    Json createDataModel(string tenantId, Json request) {
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

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["model"] = saved.toJson();
        return payload;
    }

    Json listDataModels(string tenantId) {
        validateTenant(tenantId);
        Json resources = Json.emptyArray;
        foreach (item; _store.listDataModels(tenantId)) resources ~= item.toJson();

        Json payload = Json.emptyObject;
        payload["resources"] = resources;
        payload["total_results"] = cast(long)resources.length;
        return payload;
    }

    Json createExternalDataset(string tenantId, Json request) {
        validateTenant(tenantId);
        auto sourceType = toLower(requiredString(request, "source_type"));
        if (sourceType != "csv" && sourceType != "marketplace" && sourceType != "third_party") {
            throw new DatasphereValidationException("source_type must be csv, marketplace, or third_party");
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

    Json runDataFlow(string tenantId, Json request) {
        validateTenant(tenantId);
        auto name = requiredString(request, "name");

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["tenant_id"] = tenantId;
        payload["flow_id"] = optionalString(request, "flow_id", _store.nextId("flow"));
        payload["name"] = name;
        payload["status"] = "completed";
        payload["mode"] = optionalString(request, "mode", "transform");
        return payload;
    }

    Json replicateModel(string tenantId, Json request) {
        validateTenant(tenantId);
        auto modelId = requiredString(request, "model_id");

        DATDataModel model;
        if (!_store.getDataModel(tenantId, modelId, model)) {
            throw new DatasphereNotFoundException("Data model", modelId);
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

    Json createBusinessModel(string tenantId, Json request) {
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

    Json listBusinessModels(string tenantId) {
        validateTenant(tenantId);
        Json resources = Json.emptyArray;
        foreach (item; _store.listBusinessModels(tenantId)) resources ~= item.toJson();

        Json payload = Json.emptyObject;
        payload["resources"] = resources;
        payload["total_results"] = cast(long)resources.length;
        return payload;
    }

    Json previewBusinessModel(string tenantId, string modelId) {
        validateTenant(tenantId);

        DATBusinessModel model;
        if (!_store.getBusinessModel(tenantId, modelId, model)) {
            throw new DatasphereNotFoundException("Business model", modelId);
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

    Json createConnection(string tenantId, Json request) {
        validateTenant(tenantId);
        auto name = requiredString(request, "name");
        auto sourceType = requiredString(request, "source_type");
        auto mode = toLower(optionalString(request, "mode", "federate"));
        if (mode != "federate" && mode != "replicate" && mode != "transform_load") {
            throw new DatasphereValidationException("mode must be federate, replicate, or transform_load");
        }

        DATIntegrationConnection item;
        item.tenantId = tenantId;
        item.connectionId = optionalString(request, "connection_id", _store.nextId("conn"));
        item.name = name;
        item.sourceType = sourceType;
        item.mode = mode;
        item.secure = optionalBool(request, "secure", true);
        item.status = "connected";
        item.updatedAt = Clock.currTime();

        auto saved = _store.upsertConnection(item);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["connection"] = saved.toJson();
        return payload;
    }

    Json listConnections(string tenantId) {
        validateTenant(tenantId);
        Json resources = Json.emptyArray;
        foreach (item; _store.listConnections(tenantId)) resources ~= item.toJson();

        Json payload = Json.emptyObject;
        payload["resources"] = resources;
        payload["total_results"] = cast(long)resources.length;
        return payload;
    }

    Json migrateTrustedModels(string tenantId, Json request) {
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

    Json createSpace(string tenantId, Json request) {
        validateTenant(tenantId);

        DATSpace item;
        item.tenantId = tenantId;
        item.spaceId = optionalString(request, "space_id", _store.nextId("space"));
        item.name = requiredString(request, "name");
        item.diskGb = optionalInt(request, "disk_gb", _config.defaultSpaceDiskGb);
        item.memoryGb = optionalInt(request, "memory_gb", _config.defaultSpaceMemoryGb);
        item.priority = optionalInt(request, "priority", 5);
        item.users = stringArray(request, "users");
        item.active = true;
        item.updatedAt = Clock.currTime();

        auto saved = _store.upsertSpace(item);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["space"] = saved.toJson();
        return payload;
    }

    Json listSpaces(string tenantId) {
        validateTenant(tenantId);
        Json resources = Json.emptyArray;
        foreach (item; _store.listSpaces(tenantId)) resources ~= item.toJson();

        Json payload = Json.emptyObject;
        payload["resources"] = resources;
        payload["total_results"] = cast(long)resources.length;
        return payload;
    }

    Json updateSpace(string tenantId, string spaceId, Json request) {
        validateTenant(tenantId);
        validateId(spaceId, "Space ID");

        DATSpace item;
        if (!_store.getSpace(tenantId, spaceId, item)) {
            throw new DatasphereNotFoundException("Space", spaceId);
        }

        item.name = optionalString(request, "name", item.name);
        item.diskGb = optionalInt(request, "disk_gb", item.diskGb);
        item.memoryGb = optionalInt(request, "memory_gb", item.memoryGb);
        item.priority = optionalInt(request, "priority", item.priority);
        if ("users" in request) item.users = stringArray(request, "users");
        if ("active" in request && request["active"].type == Json.Type.bool_) item.active = request["active"].get!bool;
        item.updatedAt = Clock.currTime();

        auto saved = _store.upsertSpace(item);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["space"] = saved.toJson();
        return payload;
    }

    Json addSpaceUser(string tenantId, string spaceId, Json request) {
        validateTenant(tenantId);
        validateId(spaceId, "Space ID");

        auto user = requiredString(request, "user");

        DATSpace item;
        if (!_store.getSpace(tenantId, spaceId, item)) {
            throw new DatasphereNotFoundException("Space", spaceId);
        }

        if (!contains(item.users, user)) item.users ~= user;
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
        state.connectivityPrepared = optionalBool(request, "connectivity_prepared", state.connectivityPrepared);
        state.maintenanceMode = optionalBool(request, "maintenance_mode", state.maintenanceMode);
        state.lastMaintenance = optionalString(request, "last_maintenance", state.lastMaintenance);

        if ("users" in request) state.users = stringArray(request, "users");
        if ("custom" in request && request["custom"].type == Json.Type.object) state.custom = request["custom"];

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

    Json upsertRowPolicy(string tenantId, string policyId, Json request) {
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

    Json listRowPolicies(string tenantId) {
        validateTenant(tenantId);
        Json resources = Json.emptyArray;
        foreach (item; _store.listRowPolicies(tenantId)) resources ~= item.toJson();

        Json payload = Json.emptyObject;
        payload["resources"] = resources;
        payload["total_results"] = cast(long)resources.length;
        return payload;
    }

    Json setFunctionalAccess(string tenantId, string roleName, Json request) {
        validateTenant(tenantId);
        validateId(roleName, "Role name");

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["tenant_id"] = tenantId;
        payload["role"] = roleName;
        payload["functional_permissions"] = request;
        return payload;
    }

    Json setSpaceAccess(string tenantId, string spaceId, Json request) {
        validateTenant(tenantId);
        validateId(spaceId, "Space ID");

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["tenant_id"] = tenantId;
        payload["space_id"] = spaceId;
        payload["space_permissions"] = request;
        return payload;
    }

    Json addAuditEvent(string tenantId, Json request) {
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

    Json listAuditEvents(string tenantId) {
        validateTenant(tenantId);
        Json resources = Json.emptyArray;
        foreach (item; _store.listAuditEvents(tenantId)) resources ~= item.toJson();

        Json payload = Json.emptyObject;
        payload["resources"] = resources;
        payload["total_results"] = cast(long)resources.length;
        return payload;
    }

    Json publishCatalogAsset(string tenantId, Json request) {
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

    Json listCatalogAssets(string tenantId) {
        validateTenant(tenantId);
        Json resources = Json.emptyArray;
        foreach (item; _store.listAssets(tenantId)) resources ~= item.toJson();

        Json payload = Json.emptyObject;
        payload["resources"] = resources;
        payload["total_results"] = cast(long)resources.length;
        return payload;
    }

    Json createGlossaryTerm(string tenantId, Json request) {
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

    Json listGlossaryTerms(string tenantId) {
        validateTenant(tenantId);
        Json resources = Json.emptyArray;
        foreach (item; _store.listTerms(tenantId)) resources ~= item.toJson();

        Json payload = Json.emptyObject;
        payload["resources"] = resources;
        payload["total_results"] = cast(long)resources.length;
        return payload;
    }

    Json createKPI(string tenantId, Json request) {
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

    Json listKPIs(string tenantId) {
        validateTenant(tenantId);
        Json resources = Json.emptyArray;
        foreach (item; _store.listKPIs(tenantId)) resources ~= item.toJson();

        Json payload = Json.emptyObject;
        payload["resources"] = resources;
        payload["total_results"] = cast(long)resources.length;
        return payload;
    }

    Json listConsumptionConnectors(string tenantId) {
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

    Json odataEntity(string tenantId, string entitySet) {
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

    private void validateTenant(string tenantId) {
        validateId(tenantId, "Tenant ID");
    }

    private void validateId(string value, string fieldName) {
        if (value.length == 0) throw new DatasphereValidationException(fieldName ~ " cannot be empty");
    }

    private string requiredString(Json request, string key) {
        if (!(key in request) || request[key].type != Json.Type.string) {
            throw new DatasphereValidationException(key ~ " is required");
        }
        auto value = request[key].get!string;
        if (value.length == 0) throw new DatasphereValidationException(key ~ " cannot be empty");
        return value;
    }

    private string optionalString(Json request, string key, string fallback) {
        if (key in request && request[key].isString) {
            auto value = request[key].get!string;
            return value.length > 0 ? value : fallback;
        }
        return fallback;
    }

    private int optionalInt(Json request, string key, int fallback) {
        if (key in request && request[key].type == Json.Type.int_) {
            auto value = cast(int)request[key].get!long;
            return value > 0 ? value : fallback;
        }
        return fallback;
    }

    private bool optionalBool(Json request, string key, bool fallback) {
        if (key in request && request[key].type == Json.Type.bool_) {
            return request[key].get!bool;
        }
        return fallback;
    }

    private string[] stringArray(Json request, string key) {
        string[] values;
        if (!(key in request) || request[key].type != Json.Type.array) return values;

        foreach (item; request[key]) {
            if (item.isString) {
                auto value = item.get!string;
                if (value.length > 0) values ~= value;
            }
        }
        return values;
    }

    private bool contains(string[] values, string expected) {
        foreach (item; values) if (item == expected) return true;
        return false;
    }
}
