module uim.sap.aem.service;

import std.algorithm.searching : canFind;
import std.conv : to;
import std.datetime : Clock;
import std.string : toLower;
import std.uuid : randomUUID;

import vibe.data.json : Json;

import uim.sap.aem.config;
import uim.sap.aem.exceptions;
import uim.sap.aem.models;
import uim.sap.aem.store;

class AEMService {
    private AEMConfig _config;
    private AEMStore _store;

    this(AEMConfig config) {
        config.validate();
        _config = config;
        _store = new AEMStore;
    }

    @property const(AEMConfig) config() const {
        return _config;
    }

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

    Json createBrokerService(string tenantId, Json request) {
        validateId(tenantId, "Tenant ID");

        auto broker = brokerFromJson(tenantId, request, _config.defaultMeshRegion);
        if (broker.name.length == 0) {
            throw new AEMValidationException("Broker service name is required");
        }

        broker.updatedAt = Clock.currTime();
        auto saved = _store.upsertBroker(broker);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["broker_service"] = saved.toJson();
        return payload;
    }

    Json listBrokerServices(string tenantId) {
        validateId(tenantId, "Tenant ID");

        Json resources = Json.emptyArray;
        foreach (broker; _store.listBrokers(tenantId)) {
            resources ~= broker.toJson();
        }

        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["resources"] = resources;
        payload["total_results"] = cast(long)resources.length;
        return payload;
    }

    Json createEventMesh(string tenantId, string brokerServiceId, Json request) {
        validateId(tenantId, "Tenant ID");
        validateId(brokerServiceId, "Broker service ID");

        auto broker = _store.getBroker(tenantId, brokerServiceId);
        if (broker.brokerServiceId.length == 0) {
            throw new AEMNotFoundException("Broker service", tenantId ~ "/" ~ brokerServiceId);
        }

        auto mesh = meshFromJson(tenantId, brokerServiceId, request);
        if (mesh.name.length == 0) {
            throw new AEMValidationException("Mesh name is required");
        }

        mesh.updatedAt = Clock.currTime();
        auto saved = _store.upsertMesh(mesh);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["event_mesh"] = saved.toJson();
        return payload;
    }

    Json listEventMeshes(string tenantId) {
        validateId(tenantId, "Tenant ID");

        Json resources = Json.emptyArray;
        foreach (mesh; _store.listMeshes(tenantId)) {
            resources ~= mesh.toJson();
        }

        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["resources"] = resources;
        payload["total_results"] = cast(long)resources.length;
        return payload;
    }

    Json registerTopic(string tenantId, string meshId, Json request) {
        validateId(tenantId, "Tenant ID");
        validateId(meshId, "Mesh ID");

        auto mesh = _store.getMesh(tenantId, meshId);
        if (mesh.meshId.length == 0) {
            throw new AEMNotFoundException("Event mesh", tenantId ~ "/" ~ meshId);
        }

        if (!("topic" in request) || request["topic"].type != Json.Type.string) {
            throw new AEMValidationException("topic is required");
        }

        auto topic = request["topic"].get!string;
        if (!mesh.topics.canFind(topic)) {
            mesh.topics ~= topic;
        }

        mesh.updatedAt = Clock.currTime();
        auto saved = _store.upsertMesh(mesh);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["event_mesh"] = saved.toJson();
        return payload;
    }

    Json publishEvent(string tenantId, string meshId, Json request) {
        validateId(tenantId, "Tenant ID");
        validateId(meshId, "Mesh ID");

        auto mesh = _store.getMesh(tenantId, meshId);
        if (mesh.meshId.length == 0) {
            throw new AEMNotFoundException("Event mesh", tenantId ~ "/" ~ meshId);
        }

        auto eventItem = eventFromJson(tenantId, meshId, request);
        if (eventItem.topic.length == 0) {
            throw new AEMValidationException("topic is required");
        }
        if (!mesh.topics.canFind(eventItem.topic)) {
            throw new AEMValidationException("Topic not registered in mesh: " ~ eventItem.topic);
        }

        auto savedEvent = _store.appendEvent(eventItem);

        auto broker = _store.getBroker(tenantId, mesh.brokerServiceId);
        if (broker.brokerServiceId.length > 0) {
            ++broker.eventsPublished;
            broker.updatedAt = Clock.currTime();
            _store.upsertBroker(broker);
        }

        checkAndCreateAlerts(tenantId, meshId, eventItem.topic);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["event"] = savedEvent.toJson();
        payload["message"] = "Event published to mesh topic";
        return payload;
    }

    Json listTopicEvents(string tenantId, string meshId, string topic) {
        validateId(tenantId, "Tenant ID");
        validateId(meshId, "Mesh ID");
        validateId(topic, "Topic");

        Json resources = Json.emptyArray;
        foreach (eventItem; _store.listTopicEvents(tenantId, meshId, topic)) {
            resources ~= eventItem.toJson();
        }

        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["mesh_id"] = meshId;
        payload["topic"] = topic;
        payload["resources"] = resources;
        payload["total_results"] = cast(long)resources.length;
        return payload;
    }

    Json upsertComponent(string tenantId, Json request) {
        validateId(tenantId, "Tenant ID");

        auto component = componentFromJson(tenantId, request);
        if (component.name.length == 0) {
            throw new AEMValidationException("Component name is required");
        }
        if (component.componentType.length == 0) {
            throw new AEMValidationException("Component type is required");
        }

        component.updatedAt = Clock.currTime();
        auto saved = _store.upsertComponent(component);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["component"] = saved.toJson();
        return payload;
    }

    Json listComponents(string tenantId) {
        validateId(tenantId, "Tenant ID");

        Json resources = Json.emptyArray;
        foreach (component; _store.listComponents(tenantId)) {
            resources ~= component.toJson();
        }

        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["resources"] = resources;
        payload["total_results"] = cast(long)resources.length;
        return payload;
    }

    Json addSubscription(string tenantId, string componentId, Json request) {
        validateId(tenantId, "Tenant ID");
        validateId(componentId, "Component ID");

        auto component = _store.getComponent(tenantId, componentId);
        if (component.componentId.length == 0) {
            throw new AEMNotFoundException("EDA component", tenantId ~ "/" ~ componentId);
        }

        auto subscription = subscriptionFromJson(tenantId, componentId, request);
        if (subscription.meshId.length == 0) {
            throw new AEMValidationException("mesh_id is required");
        }
        if (subscription.topic.length == 0) {
            throw new AEMValidationException("topic is required");
        }

        auto mesh = _store.getMesh(tenantId, subscription.meshId);
        if (mesh.meshId.length == 0) {
            throw new AEMNotFoundException("Event mesh", tenantId ~ "/" ~ subscription.meshId);
        }
        if (!mesh.topics.canFind(subscription.topic)) {
            throw new AEMValidationException("Topic not registered in mesh: " ~ subscription.topic);
        }

        subscription.updatedAt = Clock.currTime();
        auto saved = _store.addSubscription(subscription);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["subscription"] = saved.toJson();
        return payload;
    }

    Json modelEDA(string tenantId) {
        validateId(tenantId, "Tenant ID");

        Json nodes = Json.emptyArray;
        Json edges = Json.emptyArray;

        foreach (broker; _store.listBrokers(tenantId)) {
            Json node = Json.emptyObject;
            node["id"] = "broker:" ~ broker.brokerServiceId;
            node["label"] = broker.name;
            node["type"] = "broker_service";
            nodes ~= node;
        }

        foreach (mesh; _store.listMeshes(tenantId)) {
            Json node = Json.emptyObject;
            node["id"] = "mesh:" ~ mesh.meshId;
            node["label"] = mesh.name;
            node["type"] = "event_mesh";
            nodes ~= node;

            Json edge = Json.emptyObject;
            edge["from"] = "broker:" ~ mesh.brokerServiceId;
            edge["to"] = "mesh:" ~ mesh.meshId;
            edge["relation"] = "hosts";
            edges ~= edge;
        }

        foreach (component; _store.listComponents(tenantId)) {
            Json node = Json.emptyObject;
            node["id"] = "component:" ~ component.componentId;
            node["label"] = component.name;
            node["type"] = component.componentType;
            nodes ~= node;
        }

        foreach (subscription; _store.listSubscriptions(tenantId)) {
            Json edge = Json.emptyObject;
            edge["from"] = "mesh:" ~ subscription.meshId;
            edge["to"] = "component:" ~ subscription.componentId;
            edge["relation"] = "subscribes:" ~ subscription.topic;
            edges ~= edge;
        }

        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["nodes"] = nodes;
        payload["edges"] = edges;
        return payload;
    }

    Json upsertNotificationRule(string tenantId, string ruleId, Json request) {
        validateId(tenantId, "Tenant ID");
        validateId(ruleId, "Rule ID");

        auto rule = notificationRuleFromJson(tenantId, ruleId, request);
        if (rule.metric.length == 0) {
            throw new AEMValidationException("metric is required");
        }
        if (rule.threshold <= 0) {
            throw new AEMValidationException("threshold must be greater than zero");
        }

        rule.updatedAt = Clock.currTime();
        auto saved = _store.upsertNotificationRule(rule);

        Json payload = Json.emptyObject;
        payload["success"] = true;
        payload["notification_rule"] = saved.toJson();
        return payload;
    }

    Json listNotificationRules(string tenantId) {
        validateId(tenantId, "Tenant ID");

        Json resources = Json.emptyArray;
        foreach (rule; _store.listNotificationRules(tenantId)) {
            resources ~= rule.toJson();
        }

        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["resources"] = resources;
        payload["total_results"] = cast(long)resources.length;
        return payload;
    }

    Json monitoringDashboard(string tenantId) {
        validateId(tenantId, "Tenant ID");

        auto brokers = _store.listBrokers(tenantId);
        auto meshes = _store.listMeshes(tenantId);
        auto alerts = _store.listAlerts(tenantId);

        long totalTopics = 0;
        long totalEventsPublished = 0;
        Json brokerCards = Json.emptyArray;

        foreach (broker; brokers) {
            long meshCount = 0;
            long topicCount = 0;
            foreach (mesh; meshes) {
                if (mesh.brokerServiceId == broker.brokerServiceId) {
                    ++meshCount;
                    topicCount += cast(long)mesh.topics.length;
                }
            }

            totalTopics += topicCount;
            totalEventsPublished += broker.eventsPublished;

            Json card = Json.emptyObject;
            card["broker_service_id"] = broker.brokerServiceId;
            card["name"] = broker.name;
            card["status"] = broker.status;
            card["meshes"] = meshCount;
            card["topics"] = topicCount;
            card["events_published"] = broker.eventsPublished;
            brokerCards ~= card;
        }

        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["broker_services"] = cast(long)brokers.length;
        payload["event_meshes"] = cast(long)meshes.length;
        payload["topics"] = totalTopics;
        payload["events_published"] = totalEventsPublished;
        payload["active_alerts"] = cast(long)alerts.length;
        payload["brokers"] = brokerCards;
        return payload;
    }

    Json listAlerts(string tenantId) {
        validateId(tenantId, "Tenant ID");

        Json resources = Json.emptyArray;
        foreach (alert; _store.listAlerts(tenantId)) {
            resources ~= alert.toJson();
        }

        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["resources"] = resources;
        payload["total_results"] = cast(long)resources.length;
        return payload;
    }

    private void checkAndCreateAlerts(string tenantId, string meshId, string topic) {
        auto depth = cast(double)_store.topicDepth(tenantId, meshId, topic);
        foreach (rule; _store.listNotificationRules(tenantId)) {
            if (!rule.enabled) {
                continue;
            }
            if (toLower(rule.metric) == "queue_depth" && depth >= rule.threshold) {
                AEMMonitoringAlert alert;
                alert.tenantId = tenantId;
                alert.alertId = randomUUID().toString();
                alert.metric = "queue_depth";
                alert.currentValue = depth;
                alert.threshold = rule.threshold;
                alert.severity = rule.severity;
                alert.message = "Queue depth for topic '" ~ topic ~ "' reached " ~ to!string(depth);
                alert.acknowledged = false;
                alert.createdAt = Clock.currTime();
                _store.appendAlert(alert);
            }
        }
    }

    private void validateId(string value, string fieldName) {
        if (value.length == 0) {
            throw new AEMValidationException(fieldName ~ " cannot be empty");
        }
    }
}
