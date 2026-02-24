module uim.sap.aem.models;

import std.datetime : Clock, SysTime;
import std.string : toLower;
import std.uuid : randomUUID;

import vibe.data.json : Json;

struct AEMBrokerService {
    string tenantId;
    string brokerServiceId;
    string name;
    string plan;
    string region;
    string status = "running";

    long connectedClients;
    long eventsPublished;

    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["broker_service_id"] = brokerServiceId;
        payload["name"] = name;
        payload["plan"] = plan;
        payload["region"] = region;
        payload["status"] = status;
        payload["connected_clients"] = connectedClients;
        payload["events_published"] = eventsPublished;
        payload["created_at"] = createdAt.toISOExtString();
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

struct AEMEventMesh {
    string tenantId;
    string meshId;
    string brokerServiceId;
    string name;
    string[] topics;
    SysTime createdAt;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        Json topicsJson = Json.emptyArray;
        foreach (topic; topics) {
            topicsJson ~= topic;
        }

        payload["tenant_id"] = tenantId;
        payload["mesh_id"] = meshId;
        payload["broker_service_id"] = brokerServiceId;
        payload["name"] = name;
        payload["topics"] = topicsJson;
        payload["created_at"] = createdAt.toISOExtString();
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

struct AEMTopicEvent {
    string tenantId;
    string meshId;
    string eventId;
    string topic;
    string publisher;
    Json payload;
    SysTime publishedAt;

    Json toJson() const {
        Json out = Json.emptyObject;
        out["tenant_id"] = tenantId;
        out["mesh_id"] = meshId;
        out["event_id"] = eventId;
        out["topic"] = topic;
        out["publisher"] = publisher;
        out["payload"] = payload;
        out["published_at"] = publishedAt.toISOExtString();
        return out;
    }
}

struct AEMEDAComponent {
    string tenantId;
    string componentId;
    string name;
    string componentType;
    string owner;
    string lifecycle = "active";
    SysTime updatedAt;

    Json toJson() const {
        Json out = Json.emptyObject;
        out["tenant_id"] = tenantId;
        out["component_id"] = componentId;
        out["name"] = name;
        out["component_type"] = componentType;
        out["owner"] = owner;
        out["lifecycle"] = lifecycle;
        out["updated_at"] = updatedAt.toISOExtString();
        return out;
    }
}

struct AEMSubscription {
    string tenantId;
    string subscriptionId;
    string componentId;
    string meshId;
    string topic;
    SysTime updatedAt;

    Json toJson() const {
        Json out = Json.emptyObject;
        out["tenant_id"] = tenantId;
        out["subscription_id"] = subscriptionId;
        out["component_id"] = componentId;
        out["mesh_id"] = meshId;
        out["topic"] = topic;
        out["updated_at"] = updatedAt.toISOExtString();
        return out;
    }
}

struct AEMNotificationRule {
    string tenantId;
    string ruleId;
    string metric;
    double threshold;
    string severity = "warning";
    bool enabled = true;
    string channel = "email";
    SysTime updatedAt;

    Json toJson() const {
        Json out = Json.emptyObject;
        out["tenant_id"] = tenantId;
        out["rule_id"] = ruleId;
        out["metric"] = metric;
        out["threshold"] = threshold;
        out["severity"] = severity;
        out["enabled"] = enabled;
        out["channel"] = channel;
        out["updated_at"] = updatedAt.toISOExtString();
        return out;
    }
}

struct AEMMonitoringAlert {
    string tenantId;
    string alertId;
    string metric;
    double currentValue;
    double threshold;
    string severity;
    string message;
    bool acknowledged;
    SysTime createdAt;

    Json toJson() const {
        Json out = Json.emptyObject;
        out["tenant_id"] = tenantId;
        out["alert_id"] = alertId;
        out["metric"] = metric;
        out["current_value"] = currentValue;
        out["threshold"] = threshold;
        out["severity"] = severity;
        out["message"] = message;
        out["acknowledged"] = acknowledged;
        out["created_at"] = createdAt.toISOExtString();
        return out;
    }
}

AEMBrokerService brokerFromJson(string tenantId, Json request, string defaultRegion) {
    AEMBrokerService broker;
    broker.tenantId = tenantId;
    broker.brokerServiceId = randomUUID().toString();
    broker.plan = "standard";
    broker.region = defaultRegion;
    broker.createdAt = Clock.currTime();
    broker.updatedAt = broker.createdAt;

    if ("broker_service_id" in request && request["broker_service_id"].type == Json.Type.string) {
        broker.brokerServiceId = request["broker_service_id"].get!string;
    }
    if ("name" in request && request["name"].type == Json.Type.string) {
        broker.name = request["name"].get!string;
    }
    if ("plan" in request && request["plan"].type == Json.Type.string) {
        broker.plan = request["plan"].get!string;
    }
    if ("region" in request && request["region"].type == Json.Type.string) {
        broker.region = request["region"].get!string;
    }
    if ("status" in request && request["status"].type == Json.Type.string) {
        broker.status = toLower(request["status"].get!string);
    }

    return broker;
}

AEMEventMesh meshFromJson(string tenantId, string brokerServiceId, Json request) {
    AEMEventMesh mesh;
    mesh.tenantId = tenantId;
    mesh.meshId = randomUUID().toString();
    mesh.brokerServiceId = brokerServiceId;
    mesh.createdAt = Clock.currTime();
    mesh.updatedAt = mesh.createdAt;

    if ("mesh_id" in request && request["mesh_id"].type == Json.Type.string) {
        mesh.meshId = request["mesh_id"].get!string;
    }
    if ("name" in request && request["name"].type == Json.Type.string) {
        mesh.name = request["name"].get!string;
    }
    if ("topics" in request && request["topics"].type == Json.Type.array) {
        foreach (topicJson; request["topics"].get!(Json[])) {
            if (topicJson.type == Json.Type.string) {
                mesh.topics ~= topicJson.get!string;
            }
        }
    }

    return mesh;
}

AEMEDAComponent componentFromJson(string tenantId, Json request) {
    AEMEDAComponent component;
    component.tenantId = tenantId;
    component.componentId = randomUUID().toString();
    component.updatedAt = Clock.currTime();

    if ("component_id" in request && request["component_id"].type == Json.Type.string) {
        component.componentId = request["component_id"].get!string;
    }
    if ("name" in request && request["name"].type == Json.Type.string) {
        component.name = request["name"].get!string;
    }
    if ("component_type" in request && request["component_type"].type == Json.Type.string) {
        component.componentType = request["component_type"].get!string;
    }
    if ("owner" in request && request["owner"].type == Json.Type.string) {
        component.owner = request["owner"].get!string;
    }
    if ("lifecycle" in request && request["lifecycle"].type == Json.Type.string) {
        component.lifecycle = request["lifecycle"].get!string;
    }

    return component;
}

AEMSubscription subscriptionFromJson(string tenantId, string componentId, Json request) {
    AEMSubscription subscription;
    subscription.tenantId = tenantId;
    subscription.subscriptionId = randomUUID().toString();
    subscription.componentId = componentId;
    subscription.updatedAt = Clock.currTime();

    if ("subscription_id" in request && request["subscription_id"].type == Json.Type.string) {
        subscription.subscriptionId = request["subscription_id"].get!string;
    }
    if ("mesh_id" in request && request["mesh_id"].type == Json.Type.string) {
        subscription.meshId = request["mesh_id"].get!string;
    }
    if ("topic" in request && request["topic"].type == Json.Type.string) {
        subscription.topic = request["topic"].get!string;
    }

    return subscription;
}

AEMNotificationRule notificationRuleFromJson(string tenantId, string ruleId, Json request) {
    AEMNotificationRule rule;
    rule.tenantId = tenantId;
    rule.ruleId = ruleId;
    rule.metric = "queue_depth";
    rule.threshold = 100.0;
    rule.updatedAt = Clock.currTime();

    if ("metric" in request && request["metric"].type == Json.Type.string) {
        rule.metric = toLower(request["metric"].get!string);
    }
    if ("threshold" in request && request["threshold"].type == Json.Type.float_) {
        rule.threshold = request["threshold"].get!double;
    } else if ("threshold" in request && request["threshold"].type == Json.Type.int_) {
        rule.threshold = cast(double)request["threshold"].get!long;
    }
    if ("severity" in request && request["severity"].type == Json.Type.string) {
        rule.severity = toLower(request["severity"].get!string);
    }
    if ("enabled" in request && request["enabled"].type == Json.Type.bool_) {
        rule.enabled = request["enabled"].get!bool;
    }
    if ("channel" in request && request["channel"].type == Json.Type.string) {
        rule.channel = request["channel"].get!string;
    }

    return rule;
}

AEMTopicEvent eventFromJson(string tenantId, string meshId, Json request) {
    AEMTopicEvent e;
    e.tenantId = tenantId;
    e.meshId = meshId;
    e.eventId = randomUUID().toString();
    e.publisher = "unknown";
    e.payload = Json.emptyObject;
    e.publishedAt = Clock.currTime();

    if ("event_id" in request && request["event_id"].type == Json.Type.string) {
        e.eventId = request["event_id"].get!string;
    }
    if ("topic" in request && request["topic"].type == Json.Type.string) {
        e.topic = request["topic"].get!string;
    }
    if ("publisher" in request && request["publisher"].type == Json.Type.string) {
        e.publisher = request["publisher"].get!string;
    }
    if ("payload" in request) {
        e.payload = request["payload"];
    }

    return e;
}
