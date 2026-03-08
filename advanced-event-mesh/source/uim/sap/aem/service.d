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
    config.validate();
    _config = config;
    _store = new AEMStore;
  }

  override Json health() {
    Json healthInfo = super.health();
    healthInfo["ok"] = true;
    healthInfo["serviceName"] = _config.serviceName;
    healthInfo["serviceVersion"] = _config.serviceVersion;
    return healthInfo;
  }

  Json createBrokerService(string tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    auto broker = brokerFromJson(tenantId, request, _config.defaultMeshRegion);
    if (broker.name.length == 0) {
      throw new AEMValidationException("Broker service name is required");
    }

    broker.updatedAt = Clock.currTime();
    auto saved = _store.upsertBroker(broker);

    Json result = Json.emptyObject;
    result["success"] = true;
    result["broker_service"] = saved.toJson();
    return result;
  }

  Json listBrokerServices(string tenantId) {
    validateId(tenantId, "Tenant ID");

    Json resources = Json.emptyArray;
    foreach (broker; _store.listBrokers(tenantId)) {
      resources ~= broker.toJson();
    }

    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["resources"] = resources;
    result["total_results"] = cast(long)resources.length;
    return result;
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

    Json result = Json.emptyObject;
    result["success"] = true;
    result["event_mesh"] = saved.toJson();
    return result;
  }

  Json listEventMeshes(string tenantId) {
    validateId(tenantId, "Tenant ID");

    Json resources = Json.emptyArray;
    foreach (mesh; _store.listMeshes(tenantId)) {
      resources ~= mesh.toJson();
    }

    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["resources"] = resources;
    result["total_results"] = cast(long)resources.length;
    return result;
  }

  Json registerTopic(string tenantId, string meshId, Json request) {
    validateId(tenantId, "Tenant ID");
    validateId(meshId, "Mesh ID");

    auto mesh = _store.getMesh(tenantId, meshId);
    if (mesh.meshId.length == 0) {
      throw new AEMNotFoundException("Event mesh", tenantId ~ "/" ~ meshId);
    }

    if (!("topic" in request) || !request["topic"].isString) {
      throw new AEMValidationException("topic is required");
    }

    auto topic = request["topic"].get!string;
    if (!mesh.topics.canFind(topic)) {
      mesh.topics ~= topic;
    }

    mesh.updatedAt = Clock.currTime();
    auto saved = _store.upsertMesh(mesh);

    Json result = Json.emptyObject;
    result["success"] = true;
    result["event_mesh"] = saved.toJson();
    return result;
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

    Json result = Json.emptyObject;
    result["success"] = true;
    result["event"] = savedEvent.toJson();
    result["message"] = "Event published to mesh topic";
    return result;
  }

  Json listTopicEvents(string tenantId, string meshId, string topic) {
    validateId(tenantId, "Tenant ID");
    validateId(meshId, "Mesh ID");
    validateId(topic, "Topic");

    Json resources = Json.emptyArray;
    foreach (eventItem; _store.listTopicEvents(tenantId, meshId, topic)) {
      resources ~= eventItem.toJson();
    }

    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["mesh_id"] = meshId;
    result["topic"] = topic;
    result["resources"] = resources;
    result["total_results"] = cast(long)resources.length;
    return result;
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

    Json result = Json.emptyObject;
    result["success"] = true;
    result["component"] = saved.toJson();
    return result;
  }

  Json listComponents(string tenantId) {
    validateId(tenantId, "Tenant ID");

    Json resources = Json.emptyArray;
    foreach (component; _store.listComponents(tenantId)) {
      resources ~= component.toJson();
    }

    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["resources"] = resources;
    result["total_results"] = cast(long)resources.length;
    return result;
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

    Json result = Json.emptyObject;
    result["success"] = true;
    result["subscription"] = saved.toJson();
    return result;
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

    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["nodes"] = nodes;
    result["edges"] = edges;
    return result;
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

    Json result = Json.emptyObject;
    result["success"] = true;
    result["notification_rule"] = saved.toJson();
    return result;
  }

  Json listNotificationRules(string tenantId) {
    validateId(tenantId, "Tenant ID");

    Json resources = Json.emptyArray;
    foreach (rule; _store.listNotificationRules(tenantId)) {
      resources ~= rule.toJson();
    }

    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["resources"] = resources;
    result["total_results"] = cast(long)resources.length;
    return result;
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

    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["broker_services"] = cast(long)brokers.length;
    result["event_meshes"] = cast(long)meshes.length;
    result["topics"] = totalTopics;
    result["events_published"] = totalEventsPublished;
    result["active_alerts"] = cast(long)alerts.length;
    result["brokers"] = brokerCards;
    return result;
  }

  Json listAlerts(string tenantId) {
    validateId(tenantId, "Tenant ID");

    Json resources = Json.emptyArray;
    foreach (alert; _store.listAlerts(tenantId)) {
      resources ~= alert.toJson();
    }

    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["resources"] = resources;
    result["total_results"] = cast(long)resources.length;
    return result;
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
