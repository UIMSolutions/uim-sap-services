/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.aem.service;

import uim.sap.aem;

mixin(ShowModule!());

@safe:

class AEMService : SAPService {
  mixin(SAPServiceTemplate!AEMService);

  private AEMStore _store;

  this(AEMConfig config) {
    super(config);
    _store = new AEMStore;
  }

  Json createBrokerService(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    AEMConfig cfg = cast(AEMConfig)_config;
    auto broker = AEMBrokerService(tenantId, request, cfg.defaultMeshRegion);
    if (broker.name.length == 0) {
      throw new AEMValidationException("Broker service name is required");
    }

    broker.updatedAt = Clock.currTime();
    auto saved = _store.upsertBroker(broker);

    Json result = Json.emptyObject
      .set("success", true)
      .set("broker_service", saved.toJson());
  }

  Json listBrokerServices(UUID tenantId) {
    validateId(tenantId, "Tenant ID");

    Json resources = _store.listBrokers(tenantId).map!(resource => broker.toJson()).array.toJson;

    Json result = Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json createEventMesh(UUID tenantId, string brokerServiceId, Json request) {
    validateId(tenantId, "Tenant ID");
    validateId(brokerServiceId, "Broker service ID");

    auto broker = _store.getBroker(tenantId, brokerServiceId);
    if (broker.brokerServiceId.length == 0) {
      throw new AEMNotFoundException("Broker service", tenantId ~ "/" ~ brokerServiceId);
    }

    AEMConfig cfg = cast(AEMConfig)_config;
    auto mesh = meshFromJson(tenantId, brokerServiceId, request, cfg.defaultMeshRegion);
    if (mesh.name.length == 0) {
      throw new AEMValidationException("Mesh name is required");
    }

    mesh.updatedAt = Clock.currTime();
    auto saved = _store.upsertMesh(mesh);

    Json result = Json.emptyObject
      .set("success", true)
      .set("event_mesh", saved.toJson());
  }

  Json listEventMeshes(UUID tenantId) {
    validateId(tenantId, "Tenant ID");

    Json resources = _store.listMeshes(tenantId).map!(mesh => mesh.toJson()).array.toJson;

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json registerTopic(UUID tenantId, string meshId, Json request) {
    validateId(tenantId, "Tenant ID");
    validateId(meshId, "Mesh ID");

    auto mesh = _store.getMesh(tenantId, meshId);
    if (mesh.meshId.length == 0) {
      throw new AEMNotFoundException("Event mesh", tenantId ~ "/" ~ meshId);
    }

    if (!("topic" in request) || !request["topic"].isString) {
      throw new AEMValidationException("topic is required");
    }

    auto topic = request["topic"].getString;
    if (!mesh.topics.canFind(topic)) {
      mesh.topics ~= topic;
    }

    mesh.updatedAt = Clock.currTime();
    auto saved = _store.upsertMesh(mesh);

    return Json.emptyObject
    .set("success", true)
    .set("event_mesh", saved.toJson());
  }

  Json publishEvent(UUID tenantId, string meshId, Json request) {
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

    Json result = Json.emptyObject
      .set("success", true)
      .set("event", savedEvent.toJson())
      .set("message", "Event published to mesh topic");
  }

  Json listTopicEvents(UUID tenantId, string meshId, string topic) {
    validateId(tenantId, "Tenant ID");
    validateId(meshId, "Mesh ID");
    validateId(topic, "Topic");

    Json resources = _store.listTopicEvents(tenantId, meshId, topic)
      .map!(event => event.toJson).array.toJson();

    Json result = Json.emptyObject
      .set("tenant_id", tenantId)
      .set("mesh_id", meshId)
      .set("topic", topic)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json upsertComponent(UUID tenantId, Json request) {
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

    return Json.emptyObject
      .set("success", true)
      .set("component", saved.toJson());
  }

  Json listComponents(UUID tenantId) {
    validateId(tenantId, "Tenant ID");

    Json resources = Json.emptyArray;
    foreach (component; _store.listComponents(tenantId)) {
      resources ~= component.toJson();
    }

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json addSubscription(UUID tenantId, string componentId, Json request) {
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

    return Json.emptyObject
      .set("success", true)
      .set("subscription", saved.toJson());
  }

  Json modelEDA(UUID tenantId) {
    validateId(tenantId, "Tenant ID");

    Json nodes = Json.emptyArray;
    Json edges = Json.emptyArray;

    foreach (broker; _store.listBrokers(tenantId)) {
      Json node = Json.emptyObject
      .set("id", "broker:" ~ broker.brokerServiceId)
      .set("label", broker.name)
      .set("type", "broker_service");
      nodes ~= node;
    }

    foreach (mesh; _store.listMeshes(tenantId)) {
      Json node = Json.emptyObject
      .set("id", "mesh:" ~ mesh.meshId)
      .set("label", mesh.name)
      .set("type", "event_mesh");
      nodes ~= node;

      Json edge = Json.emptyObject
      .set("from", "broker:" ~ mesh.brokerServiceId)
      .set("to", "mesh:" ~ mesh.meshId)
      .set("relation", "hosts");
      edges ~= edge;
    }

    foreach (component; _store.listComponents(tenantId)) {
      Json node = Json.emptyObject
      .set("id", "component:" ~ component.componentId)
      .set("label", component.name)
      .set("type", component.componentType);
      nodes ~= node;
    }

    foreach (subscription; _store.listSubscriptions(tenantId)) {
      Json edge = Json.emptyObject
      .set("from", "mesh:" ~ subscription.meshId)
      .set("to", "component:" ~ subscription.componentId)
      .set("relation", "subscribes:" ~ subscription.topic);
      edges ~= edge;
    }

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("nodes", nodes)
      .set("edges", edges);
  }

  Json upsertNotificationRule(UUID tenantId, string ruleId, Json request) {
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

    return Json.emptyObject
      .set("success", true)
      .set("notification_rule", saved.toJson());
  }

  Json listNotificationRules(UUID tenantId) {
    validateId(tenantId, "Tenant ID");

    Json resources = _store.listNotificationRules(tenantId).map!(rule => rule.toJson()).array.toJson; 

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json monitoringDashboard(UUID tenantId) {
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

      Json card = Json.emptyObject
      .set("broker_service_id", broker.brokerServiceId)
      .set("name", broker.name)
      .set("status", broker.status)
      .set("meshes", meshCount)
      .set("topics", topicCount)
      .set("events_published", broker.eventsPublished);
      brokerCards ~= card;
    }

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("broker_services", cast(long)brokers.length)
      .set("event_meshes", cast(long)meshes.length)
      .set("topics", totalTopics)
      .set("events_published", totalEventsPublished)
      .set("active_alerts", cast(long)alerts.length)
      .set("brokers", brokerCards);
  }

  Json listAlerts(UUID tenantId) {
    validateId(tenantId, "Tenant ID");

    Json resources = Json.emptyArray;
    foreach (alert; _store.listAlerts(tenantId)) {
      resources ~= alert.toJson();
    }

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  private void checkAndCreateAlerts(UUID tenantId, string meshId, string topic) {
    auto depth = cast(double)_store.topicDepth(tenantId, meshId, topic);
    foreach (rule; _store.listNotificationRules(tenantId)) {
      if (!rule.enabled) {
        continue;
      }
      if (toLower(rule.metric) == "queue_depth" && depth >= rule.threshold) {
        AEMMonitoringAlert alert;
        alert.tenantId = tenantId;
        alert.alertId = randomUUID();
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
}
