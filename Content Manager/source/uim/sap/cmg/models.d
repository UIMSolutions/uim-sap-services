module uim.sap.cmg.models;

import std.datetime : SysTime;

import vibe.data.json : Json;

struct CMGContentItem {
    string tenantId;
    string itemId;
    string contentType;
    string title;
    string description;
    string source;
    string sourceRef;
    string[] tags;
    Json config;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["item_id"] = itemId;
        payload["content_type"] = contentType;
        payload["title"] = title;
        payload["description"] = description;
        payload["source"] = source;
        payload["source_ref"] = sourceRef;

        Json tagValues = Json.emptyArray;
        foreach (tag; tags) tagValues ~= tag;
        payload["tags"] = tagValues;

        payload["config"] = config;
        payload["created_at"] = createdAt.toISOExtString();
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

struct CMGContentProvider {
    string tenantId;
    string providerId;
    string name;
    string providerType;
    string endpoint;
    string[] exposedTypes;
    bool active;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["provider_id"] = providerId;
        payload["name"] = name;
        payload["provider_type"] = providerType;
        payload["endpoint"] = endpoint;

        Json typeValues = Json.emptyArray;
        foreach (t; exposedTypes) typeValues ~= t;
        payload["exposed_types"] = typeValues;

        payload["active"] = active;
        payload["created_at"] = createdAt.toISOExtString();
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}
