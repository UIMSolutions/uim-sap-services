module uim.sap.mdi.service;

import std.datetime : Clock;
import std.string : toLower;

import vibe.data.json : Json;

import uim.sap.mdi.config;
import uim.sap.mdi.exceptions;
import uim.sap.mdi.models;
import uim.sap.mdi.store;

class MDIService : SAPService {
    private MDIConfig _config;
    private MDIStore _store;

    this(MDIConfig config) {
        config.validate();
        _config = config;
        _store = new MDIStore;
    }

    @property const(MDIConfig) config() const { return _config; }

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
        payload["timestamp"] = Clock.currTime().toISOExtString();
        return payload;
    }

    Json upsertClient(string tenantId, Json request) {
        validateId(tenantId, "Tenant ID");
        auto client = clientFromJson(tenantId, request);
        if (client.name.length == 0) throw new MDIValidationException("name is required");
        auto saved = _store.upsertClient(client);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["client"] = saved.toJson();
        return payload;
    }

    Json listClients(string tenantId) {
        validateId(tenantId, "Tenant ID");
        Json resources = Json.emptyArray;
        foreach (client; _store.listClients(tenantId)) resources ~= client.toJson();

        Json payload = Json.emptyObject;
        payload["resources"] = resources;
        payload["total_results"] = cast(long)resources.length;
        return payload;
    }

    Json upsertFilter(string tenantId, string filterId, Json request) {
        validateId(tenantId, "Tenant ID");
        validateId(filterId, "Filter ID");

        MDIFilter filter;
        filter.tenantId = tenantId;
        filter.filterId = filterId;
        filter.objectType = _config.defaultObjectType;
        filter.conditions = Json.emptyArray;
        filter.active = true;
        filter.updatedAt = Clock.currTime();

        if ("object_type" in request && request["object_type"].isString) filter.objectType = toLower(request["object_type"].get!string);
        if ("conditions" in request && request["conditions"].type == Json.Type.array) filter.conditions = request["conditions"];
        if ("active" in request && request["active"].isBoolean) filter.active = request["active"].get!bool;

        if (!isAllowedObjectType(filter.objectType)) throw new MDIValidationException("Unsupported object_type");

        auto saved = _store.upsertFilter(filter);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["filter"] = saved.toJson();
        payload["managed_by"] = "sap-business-data-orchestration-compatible";
        return payload;
    }

    Json listFilters(string tenantId) {
        validateId(tenantId, "Tenant ID");
        Json resources = Json.emptyArray;
        foreach (filter; _store.listFilters(tenantId)) resources ~= filter.toJson();

        Json payload = Json.emptyObject;
        payload["resources"] = resources;
        payload["total_results"] = cast(long)resources.length;
        return payload;
    }

    Json upsertExtension(string tenantId, string extensionId, Json request) {
        validateId(tenantId, "Tenant ID");
        validateId(extensionId, "Extension ID");

        MDIExtension extension;
        extension.tenantId = tenantId;
        extension.extensionId = extensionId;
        extension.objectType = _config.defaultObjectType;
        extension.fields = Json.emptyArray;
        extension.entities = Json.emptyArray;
        extension.updatedAt = Clock.currTime();

        if ("object_type" in request && request["object_type"].isString) extension.objectType = toLower(request["object_type"].get!string);
        if ("fields" in request && request["fields"].type == Json.Type.array) extension.fields = request["fields"];
        if ("entities" in request && request["entities"].type == Json.Type.array) extension.entities = request["entities"];

        if (!isAllowedObjectType(extension.objectType)) throw new MDIValidationException("Unsupported object_type");

        auto saved = _store.upsertExtension(extension);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["extension"] = saved.toJson();
        payload["extensibility"] = true;
        return payload;
    }

    Json listExtensions(string tenantId) {
        validateId(tenantId, "Tenant ID");
        Json resources = Json.emptyArray;
        foreach (extension; _store.listExtensions(tenantId)) resources ~= extension.toJson();

        Json payload = Json.emptyObject;
        payload["resources"] = resources;
        payload["total_results"] = cast(long)resources.length;
        return payload;
    }

    Json replicate(string tenantId, Json request) {
        validateId(tenantId, "Tenant ID");

        if (!("source_client_id" in request) || request["source_client_id"].type != Json.Type.string) {
            throw new MDIValidationException("source_client_id is required");
        }
        if (!("target_client_id" in request) || request["target_client_id"].type != Json.Type.string) {
            throw new MDIValidationException("target_client_id is required");
        }

        auto sourceClientId = request["source_client_id"].get!string;
        auto targetClientId = request["target_client_id"].get!string;

        auto source = _store.getClient(tenantId, sourceClientId);
        auto target = _store.getClient(tenantId, targetClientId);
        if (source.clientId.length == 0) throw new MDINotFoundException("Source client", sourceClientId);
        if (target.clientId.length == 0) throw new MDINotFoundException("Target client", targetClientId);

        MDIReplicationJob job;
        job.tenantId = tenantId;
        job.jobId = createId();
        job.sourceClientId = sourceClientId;
        job.targetClientId = targetClientId;
        job.objectType = _config.defaultObjectType;
        job.mode = "incremental";
        job.status = "completed";
        job.filterIds = Json.emptyArray;
        job.createdAt = Clock.currTime();
        job.updatedAt = job.createdAt;

        if ("object_type" in request && request["object_type"].isString) job.objectType = toLower(request["object_type"].get!string);
        if ("mode" in request && request["mode"].isString) job.mode = request["mode"].get!string;
        if ("filter_ids" in request && request["filter_ids"].type == Json.Type.array) job.filterIds = request["filter_ids"];

        if (!isAllowedObjectType(job.objectType)) throw new MDIValidationException("Unsupported object_type");

        auto saved = _store.upsertJob(job);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["replication"] = saved.toJson();
        payload["replicated_between"] = Json.emptyObject;
        payload["replicated_between"]["source"] = source.toJson();
        payload["replicated_between"]["target"] = target.toJson();
        return payload;
    }

    Json listReplications(string tenantId) {
        validateId(tenantId, "Tenant ID");
        Json resources = Json.emptyArray;
        foreach (job; _store.listJobs(tenantId)) resources ~= job.toJson();

        Json payload = Json.emptyObject;
        payload["resources"] = resources;
        payload["total_results"] = cast(long)resources.length;
        return payload;
    }

    private void validateId(string value, string fieldName) {
        if (value.length == 0) throw new MDIValidationException(fieldName ~ " cannot be empty");
    }
}
