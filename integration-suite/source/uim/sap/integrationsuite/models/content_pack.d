/**
 * Content Pack model — Pre-built integration content
 *
 * Represents a best-practice integration pack for faster time-to-value.
 */
module uim.sap.integrationsuite.models.content_pack;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

struct ISContentPack {
    string tenantId;
    string packId;
    string name;
    string description;
    string vendor;
    string version_ = "1.0.0";
    string category;                     // e.g. procurement, finance, hr
    string[] iflowIds;
    string[] mappingIds;
    string status = "available";         // available | installed | deprecated
    string installedAt;
    string createdAt;
    string updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"] = tenantId;
        j["pack_id"] = packId;
        j["name"] = name;
        j["description"] = description;
        j["vendor"] = vendor;
        j["version"] = version_;
        j["category"] = category;

        Json flows = Json.emptyArray;
        foreach (id; iflowIds) flows ~= Json(id);
        j["iflow_ids"] = flows;

        Json maps = Json.emptyArray;
        foreach (id; mappingIds) maps ~= Json(id);
        j["mapping_ids"] = maps;

        j["status"] = status;
        j["installed_at"] = installedAt;
        j["created_at"] = createdAt;
        j["updated_at"] = updatedAt;
        return j;
    }
}

ISContentPack contentPackFromJson(string tenantId, Json request) {
    ISContentPack p;
    p.tenantId = tenantId;
    p.packId = randomUUID().toString();

    if ("name" in request && request["name"].isString)
        p.name = request["name"].get!string;
    if ("description" in request && request["description"].isString)
        p.description = request["description"].get!string;
    if ("vendor" in request && request["vendor"].isString)
        p.vendor = request["vendor"].get!string;
    if ("version" in request && request["version"].isString)
        p.version_ = request["version"].get!string;
    if ("category" in request && request["category"].isString)
        p.category = request["category"].get!string;
    if ("iflow_ids" in request && request["iflow_ids"].type == Json.Type.array) {
        foreach (item; request["iflow_ids"]) {
            if (item.isString) p.iflowIds ~= item.get!string;
        }
    }
    if ("mapping_ids" in request && request["mapping_ids"].type == Json.Type.array) {
        foreach (item; request["mapping_ids"]) {
            if (item.isString) p.mappingIds ~= item.get!string;
        }
    }

    p.createdAt = Clock.currTime().toISOExtString();
    p.updatedAt = p.createdAt;
    return p;
}
