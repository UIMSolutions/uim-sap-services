module uim.sap.mdi.models.extension;

struct MDIExtension {
    string tenantId;
    string extensionId;
    string objectType;
    Json fields;
    Json entities;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["extension_id"] = extensionId;
        payload["object_type"] = objectType;
        payload["fields"] = fields;
        payload["entities"] = entities;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}