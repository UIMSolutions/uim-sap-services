module uim.sap.cag.models.models;

import std.datetime : SysTime;

import vibe.data.json : Json;

struct CAGContentProvider {
    string tenantId;
    string providerId;
    string name;
    string providerType;
    string endpoint;
    string[] supportedTypes;
    bool active;
    SysTime createdAt;
    SysTime updatedAt;

    override Json toJson()  {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["provider_id"] = providerId;
        payload["name"] = name;
        payload["provider_type"] = providerType;
        payload["endpoint"] = endpoint;

        Json types = Json.emptyArray;
        foreach (value; supportedTypes) types ~= value;
        payload["supported_types"] = types;

        payload["active"] = active;
        payload["created_at"] = createdAt.toISOExtString();
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

struct CAGContentItem {
    string tenantId;
    string contentId;
    string title;
    string contentType;
    string contentVersion;
    string providerId;
    string[] dependencies;
    string[] relatedContent;
    Json metadata;
    SysTime createdAt;
    SysTime updatedAt;

    override Json toJson()  {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["content_id"] = contentId;
        payload["title"] = title;
        payload["content_type"] = contentType;
        payload["version"] = contentVersion;
        payload["provider_id"] = providerId;

        Json deps = Json.emptyArray;
        foreach (value; dependencies) deps ~= value;
        payload["dependencies"] = deps;

        Json related = Json.emptyArray;
        foreach (value; relatedContent) related ~= value;
        payload["related_content"] = related;

        payload["metadata"] = metadata;
        payload["created_at"] = createdAt.toISOExtString();
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

struct CAGAssembly {
    string tenantId;
    string assemblyId;
    string name;
    string sourceSubaccount;
    string targetSubaccount;
    string[] requestedContentIds;
    string[] resolvedContentIds;
    bool includeDependencies;
    string mtarName;
    string mtarDownloadUrl;
    string status;
    SysTime createdAt;
    SysTime updatedAt;

    override Json toJson()  {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["assembly_id"] = assemblyId;
        payload["name"] = name;
        payload["source_subaccount"] = sourceSubaccount;
        payload["target_subaccount"] = targetSubaccount;

        Json requested = Json.emptyArray;
        foreach (value; requestedContentIds) requested ~= value;
        payload["requested_content_ids"] = requested;

        Json resolved = Json.emptyArray;
        foreach (value; resolvedContentIds) resolved ~= value;
        payload["resolved_content_ids"] = resolved;

        payload["include_dependencies"] = includeDependencies;
        payload["mtar_name"] = mtarName;
        payload["mtar_download_url"] = mtarDownloadUrl;
        payload["status"] = status;
        payload["created_at"] = createdAt.toISOExtString();
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

struct CAGTransportQueue {
    string tenantId;
    string queueId;
    string name;
    string queueType;
    string endpoint;
    bool active;
    SysTime createdAt;
    SysTime updatedAt;

    override Json toJson()  {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["queue_id"] = queueId;
        payload["name"] = name;
        payload["queue_type"] = queueType;
        payload["endpoint"] = endpoint;
        payload["active"] = active;
        payload["created_at"] = createdAt.toISOExtString();
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

struct CAGTransportActivity {
    string tenantId;
    string activityId;
    string assemblyId;
    string queueId;
    string status;
    string message;
    string initiatedBy;
    Json exportPayload;
    SysTime createdAt;

    override Json toJson()  {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["activity_id"] = activityId;
        payload["assembly_id"] = assemblyId;
        payload["queue_id"] = queueId;
        payload["status"] = status;
        payload["message"] = message;
        payload["initiated_by"] = initiatedBy;
        payload["export_payload"] = exportPayload;
        payload["created_at"] = createdAt.toISOExtString();
        return payload;
    }
}
