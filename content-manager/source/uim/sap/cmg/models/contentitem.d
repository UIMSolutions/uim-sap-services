module uim.sap.cmg.models.contentitem;

import uim.sap.cmg;
@safe:

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