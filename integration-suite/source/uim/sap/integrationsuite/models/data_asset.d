/**
 * Data Asset model — Data Space Integration
 *
 * Represents an asset offered or consumed within a data space.
 */
module uim.sap.integrationsuite.models.data_asset;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

struct ISDataAsset {
    string tenantId;
    string assetId;
    string name;
    string description;
    string assetType = "dataset";       // dataset | api | stream
    string format = "json";             // json | csv | parquet | xml
    string accessPolicy = "open";       // open | restricted | contractual
    string provider;
    string dataSpaceName;
    string contractId;
    string status = "available";        // available | consumed | retired
    long accessCount = 0;
    string createdAt;
    string updatedAt;

    Json toJson() const {
        Json j = Json.emptyObject;
        j["tenant_id"] = tenantId;
        j["asset_id"] = assetId;
        j["name"] = name;
        j["description"] = description;
        j["asset_type"] = assetType;
        j["format"] = format;
        j["access_policy"] = accessPolicy;
        j["provider"] = provider;
        j["data_space_name"] = dataSpaceName;
        j["contract_id"] = contractId;
        j["status"] = status;
        j["access_count"] = accessCount;
        j["created_at"] = createdAt;
        j["updated_at"] = updatedAt;
        return j;
    }
}

ISDataAsset dataAssetFromJson(string tenantId, Json request) {
    ISDataAsset a;
    a.tenantId = tenantId;
    a.assetId = randomUUID().toString();

    if ("name" in request && request["name"].type == Json.Type.string)
        a.name = request["name"].get!string;
    if ("description" in request && request["description"].type == Json.Type.string)
        a.description = request["description"].get!string;
    if ("asset_type" in request && request["asset_type"].type == Json.Type.string)
        a.assetType = request["asset_type"].get!string;
    if ("format" in request && request["format"].type == Json.Type.string)
        a.format = request["format"].get!string;
    if ("access_policy" in request && request["access_policy"].type == Json.Type.string)
        a.accessPolicy = request["access_policy"].get!string;
    if ("provider" in request && request["provider"].type == Json.Type.string)
        a.provider = request["provider"].get!string;
    if ("data_space_name" in request && request["data_space_name"].type == Json.Type.string)
        a.dataSpaceName = request["data_space_name"].get!string;
    if ("contract_id" in request && request["contract_id"].type == Json.Type.string)
        a.contractId = request["contract_id"].get!string;

    a.createdAt = Clock.currTime().toISOExtString();
    a.updatedAt = a.createdAt;
    return a;
}
