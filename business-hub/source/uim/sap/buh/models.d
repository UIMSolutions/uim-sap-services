/**
 * Models for BUH service
 */
module uim.sap.buh.models;

import std.datetime : Clock, SysTime;
import std.uuid : randomUUID;

import vibe.data.json : Json;

struct BUHApi {
    string id;
    string name;
    string provider;
    string apiVersion;
    string visibility = "public";
    string summary;
    string[] tags;
    SysTime createdAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        Json tagsJson = Json.emptyArray;
        foreach (tag; tags) {
            tagsJson ~= Json(tag);
        }

        payload["id"] = id;
        payload["name"] = name;
        payload["provider"] = provider;
        payload["version"] = apiVersion;
        payload["visibility"] = visibility;
        payload["summary"] = summary;
        payload["tags"] = tagsJson;
        payload["created_at"] = createdAt.toISOExtString();
        return payload;
    }
}

struct BUHProduct {
    string id;
    string name;
    string description;
    string[] apiIds;
    SysTime createdAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        Json apiIdsJson = Json.emptyArray;
        foreach (apiId; apiIds) {
            apiIdsJson ~= Json(apiId);
        }

        payload["id"] = id;
        payload["name"] = name;
        payload["description"] = description;
        payload["api_ids"] = apiIdsJson;
        payload["created_at"] = createdAt.toISOExtString();
        return payload;
    }
}

struct BUHSubscription {
    string id;
    string apiId;
    string applicationName;
    string plan;
    string status = "active";
    SysTime createdAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["id"] = id;
        payload["api_id"] = apiId;
        payload["application_name"] = applicationName;
        payload["plan"] = plan;
        payload["status"] = status;
        payload["created_at"] = createdAt.toISOExtString();
        return payload;
    }
}

BUHApi apiFromJson(Json payload) {
    BUHApi api;
    api.id = randomUUID().toString();
    api.createdAt = Clock.currTime();

    if ("name" in payload && payload["name"].isString) {
        api.name = payload["name"].get!string;
    }
    if ("provider" in payload && payload["provider"].isString) {
        api.provider = payload["provider"].get!string;
    }
    if ("version" in payload && payload["version"].isString) {
        api.apiVersion = payload["version"].get!string;
    }
    if ("visibility" in payload && payload["visibility"].isString) {
        api.visibility = payload["visibility"].get!string;
    }
    if ("summary" in payload && payload["summary"].isString) {
        api.summary = payload["summary"].get!string;
    }

    if ("tags" in payload && payload["tags"].type == Json.Type.array) {
        foreach (entry; payload["tags"]) {
            if (entry.isString) {
                api.tags ~= entry.get!string;
            }
        }
    }

    return api;
}

BUHProduct productFromJson(Json payload) {
    BUHProduct product;
    product.id = randomUUID().toString();
    product.createdAt = Clock.currTime();

    if ("name" in payload && payload["name"].isString) {
        product.name = payload["name"].get!string;
    }
    if ("description" in payload && payload["description"].isString) {
        product.description = payload["description"].get!string;
    }
    if ("api_ids" in payload && payload["api_ids"].type == Json.Type.array) {
        foreach (entry; payload["api_ids"]) {
            if (entry.isString) {
                product.apiIds ~= entry.get!string;
            }
        }
    }

    return product;
}

BUHSubscription subscriptionFromJson(Json payload) {
    BUHSubscription subscription;
    subscription.id = randomUUID().toString();
    subscription.createdAt = Clock.currTime();

    if ("api_id" in payload && payload["api_id"].isString) {
        subscription.apiId = payload["api_id"].get!string;
    }
    if ("application_name" in payload && payload["application_name"].isString) {
        subscription.applicationName = payload["application_name"].get!string;
    }
    if ("plan" in payload && payload["plan"].isString) {
        subscription.plan = payload["plan"].get!string;
    }

    return subscription;
}
