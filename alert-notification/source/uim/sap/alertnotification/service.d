/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.alertnotification.service;

import std.algorithm.searching : canFind;
import std.datetime : Clock;
import std.string : toLower;

import uim.sap.alertnotification;

mixin(ShowModule!());

@safe:

class AlertNotificationService : SAPService {
  mixin(SAPServiceTemplate!AlertNotificationService);

  private AlertNotificationStore _store;

  this(AlertNotificationConfig config) {
    super(config);
    _store = new AlertNotificationStore;
  }

  Json listBuiltInEvents() {
    Json resources = Json.emptyArray;
    foreach (eventType; ALERT_BUILT_IN_EVENTS) {
      Json item = Json.emptyObject;
      item["event_type"] = eventType;
      item["provider"] = "SAP BTP";
      resources ~= item;
    }

    Json result = Json.emptyObject;
    result["resources"] = resources;
    result["total_results"] = cast(long)resources.length;
    return result;
  }

  Json listDeliveryOptions() {
    Json resources = Json.emptyArray;
    foreach (option; ALERT_DELIVERY_OPTIONS) {
      resources ~= option;
    }
    Json result = Json.emptyObject;
    result["resources"] = resources;
    result["total_results"] = cast(long)resources.length;
    return result;
  }

  Json publishAlert(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    AlertEvent eventItem;
    eventItem.tenantId = UUID(tenantId);
    eventItem.alertId = request.getString("alert_id", createId());
    eventItem.eventType = requiredString(request, "event_type");
    eventItem.category = request.getString("category", "platform");
    eventItem.severity = toLower(request.getString("severity", "info"));
    eventItem.source = request.getString("source", "custom-application");
    eventItem.subject = requiredString(request, "subject");
    eventItem.message = requiredString(request, "message");
    eventItem.tags = optionalArray(request, "tags");
    eventItem.payload = optionalObject(request, "payload");
    eventItem.createdAt = Clock.currTime();

    auto saved = _store.appendAlert(eventItem);
    auto deliveries = fanOut(saved);

    Json deliveryList = Json.emptyArray;
    foreach (delivery; deliveries) {
      deliveryList ~= delivery.toJson();
    }

    Json result = Json.emptyObject;
    result["success"] = true;
    result["event"] = saved.toJson();
    result["deliveries"] = deliveryList;
    result["matched_subscriptions"] = cast(long)deliveries.length;
    return result;
  }

  Json listAlerts(UUID tenantId) {
    validateId(tenantId, "Tenant ID");

    Json resources = Json.emptyArray;
    foreach (eventItem; _store.listAlerts(tenantId)) {
      resources ~= eventItem.toJson();
    }
    Json result = Json.emptyObject;
    result["resources"] = resources;
    result["total_results"] = cast(long)resources.length;
    return result;
  }

  Json searchAlerts(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    auto eventType = toLower(optionalString(request, "event_type", ""));
    auto severity = toLower(optionalString(request, "severity", ""));
    auto source = toLower(optionalString(request, "source", ""));
    auto tags = optionalArray(request, "tags");

    Json resources = Json.emptyArray;
    foreach (eventItem; _store.listAlerts(tenantId)) {
      if (eventType.length > 0 && toLower(eventItem.eventType) != eventType) {
        continue;
      }
      if (severity.length > 0 && toLower(eventItem.severity) != severity) {
        continue;
      }
      if (source.length > 0 && toLower(eventItem.source) != source) {
        continue;
      }
      if (!containsAllTags(eventItem.tags, tags)) {
        continue;
      }
      resources ~= eventItem.toJson();
    }

    Json result = Json.emptyObject;
    result["resources"] = resources;
    result["total_results"] = cast(long)resources.length;
    return result;
  }

  Json listSubscriptions(UUID tenantId) {
    validateId(tenantId, "Tenant ID");

    Json resources = Json.emptyArray;
    foreach (sub; _store.listSubscriptions(tenantId)) {
      resources ~= sub.toJson();
    }
    Json result = Json.emptyObject;
    result["resources"] = resources;
    result["total_results"] = cast(long)resources.length;
    return result;
  }

  Json getSubscription(UUID tenantId, string subscriptionId) {
    validateId(tenantId, "Tenant ID");
    validateId(subscriptionId, "Subscription ID");

    auto sub = _store.getSubscription(tenantId, subscriptionId);
    if (sub.subscriptionId.length == 0) {
      throw new AlertNotificationNotFoundException("Subscription", tenantId ~ "/" ~ subscriptionId);
    }

    Json result = Json.emptyObject;
    result["subscription"] = sub.toJson();
    return result;
  }

  Json upsertSubscription(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    AlertSubscription sub;
    sub.tenantId = UUID(tenantId);
    sub.subscriptionId = optionalString(request, "subscription_id", createId());
    sub.name = requiredString(request, "name");
    sub.consumerId = optionalString(request, "consumer_id", "default-consumer");
    sub.enabled = request.getBoolean("enabled", true);
    sub.condition = buildCondition(request);
    sub.actions = buildActions(request);
    sub.createdAt = Clock.currTime();
    sub.updatedAt = sub.createdAt;

    auto saved = _store.upsertSubscription(sub);
    Json result = Json.emptyObject;
    result["success"] = true;
    result["subscription"] = saved.toJson();
    return result;
  }

  Json deleteSubscription(UUID tenantId, string subscriptionId) {
    validateId(tenantId, "Tenant ID");
    validateId(subscriptionId, "Subscription ID");

    if (!_store.deleteSubscription(tenantId, subscriptionId)) {
      throw new AlertNotificationNotFoundException("Subscription", tenantId ~ "/" ~ subscriptionId);
    }

    Json result = Json.emptyObject;
    result["success"] = true;
    result["subscription_id"] = subscriptionId;
    return result;
  }

  Json testSubscription(UUID tenantId, string subscriptionId, Json request) {
    auto sub = _store.getSubscription(tenantId, subscriptionId);
    if (sub.subscriptionId.length == 0) {
      throw new AlertNotificationNotFoundException("Subscription", tenantId ~ "/" ~ subscriptionId);
    }

    AlertEvent eventItem;
    eventItem.tenantId = UUID(tenantId);
    eventItem.alertId = optionalString(request, "alert_id", createId());
    eventItem.eventType = requiredString(request, "event_type");
    eventItem.severity = toLower(optionalString(request, "severity", "info"));
    eventItem.source = optionalString(request, "source", "test");
    eventItem.subject = requiredString(request, "subject");
    eventItem.message = requiredString(request, "message");
    eventItem.tags = optionalArray(request, "tags");
    eventItem.payload = optionalObject(request, "payload");
    eventItem.createdAt = Clock.currTime();

    auto matched = matchesCondition(eventItem, sub.condition);
    Json result = Json.emptyObject
    result
      .set("subscription_id", subscriptionId)
      .set("matched", matched)
      .set("event", eventItem.toJson())
      .set("condition", sub.condition);
  }

  Json listDeliveries(UUID tenantId) {
    validateId(tenantId, "Tenant ID");

    Json resources = Json.emptyArray;
    foreach (delivery; _store.listDeliveries(tenantId)) {
      resources ~= delivery.toJson();
    }
    Json result = Json.emptyObject;
    result["resources"] = resources;
    result["total_results"] = cast(long)resources.length;
    return result;
  }

  Json tenantOverview(UUID tenantId) {
    validateId(tenantId, "Tenant ID");
    auto alerts = _store.listAlerts(tenantId);
    auto subs = _store.listSubscriptions(tenantId);
    auto deliveries = _store.listDeliveries(tenantId);

    long activeSubs = 0;
    foreach (sub; subs) {
      if (sub.enabled) {
        activeSubs++;
      }
    }

    Json result = Json.emptyObject
      .set("tenant_id", tenantId)
      .set("alerts_total", cast(long)alerts.length)
      .set("subscriptions_total", cast(long)subs.length)
      .set("subscriptions_active", activeSubs)
      .set("deliveries_total", cast(long)deliveries.length)
      .set("delivery_options", listDeliveryOptions()["resources"]);
  }

  private AlertDelivery[] fanOut(AlertEvent eventItem) {
    AlertDelivery[] results;

    foreach (sub; _store.listSubscriptions(eventItem.tenantId)) {
      if (!sub.enabled) {
        continue;
      }
      if (!matchesCondition(eventItem, sub.condition)) {
        continue;
      }

      foreach (actionJson; sub.actions.toArray) {
        if (!actionJson.isObject) {
          continue;
        }

        bool actionEnabled = true;
        if ("enabled" in actionJson && actionJson["enabled"].isBoolean) {
          actionEnabled = actionJson["enabled"].get!bool;
        }
        if (!actionEnabled) {
          continue;
        }

        AlertDelivery delivery;
        delivery.tenantId = eventItem.tenantId;
        delivery.deliveryId = createId();
        delivery.alertId = eventItem.alertId;
        delivery.subscriptionId = sub.subscriptionId;
        delivery.actionType = "webhook";
        delivery.target = "unknown";
        delivery.status = "sent";
        delivery.reason = "condition-matched";
        delivery.createdAt = Clock.currTime();

        if ("action_type" in actionJson && actionJson["action_type"].isString) {
          delivery.actionType = actionJson["action_type"].get!string;
        }
        if ("target" in actionJson && actionJson["target"].isString) {
          delivery.target = actionJson["target"].get!string;
        }

        auto saved = _store.appendDelivery(delivery);
        results ~= saved;
      }
    }
    return results;
  }

  private bool matchesCondition(AlertEvent eventItem, Json condition) {
    auto eventTypes = getStringArray(condition, "event_types");
    auto severities = getStringArray(condition, "severities");
    auto sources = getStringArray(condition, "sources");
    auto tags = getStringArray(condition, "tags");

    if (eventTypes.length > 0 && !eventTypes.canFind(toLower(eventItem.eventType))) {
      return false;
    }
    if (severities.length > 0 && !severities.canFind(toLower(eventItem.severity))) {
      return false;
    }
    if (sources.length > 0 && !sources.canFind(toLower(eventItem.source))) {
      return false;
    }

    if (tags.length > 0) {
      auto eventTags = toLoweredStringArray(eventItem.tags);
      foreach (tag; tags) {
        if (!eventTags.canFind(tag)) {
          return false;
        }
      }
    }

    return true;
  }

  private bool containsAllTags(Json available, Json requested) {
    if (!requested.isArray || requested.length == 0) {
      return true;
    }

    auto haystack = toLoweredStringArray(available);
    foreach (item; requested.toArray) {
      if (!item.isString) {
        continue;
      }
      if (!haystack.canFind(toLower(item.get!string))) {
        return false;
      }
    }
    return true;
  }

  private Json buildCondition(Json request) {
    Json condition = Json.emptyObject;
    if ("condition" in request && request["condition"].isObject) {
      condition = request["condition"];
    }

    if (!("event_types" in condition)) {
      condition["event_types"] = Json.emptyArray;
    }
    if (!("severities" in condition)) {
      condition["severities"] = Json.emptyArray;
    }
    if (!("sources" in condition)) {
      condition["sources"] = Json.emptyArray;
    }
    if (!("tags" in condition)) {
      condition["tags"] = Json.emptyArray;
    }
    return condition;
  }

  private Json buildActions(Json request) {
    Json actions = Json.emptyArray;
    if ("actions" in request && request["actions"].isArray) {
      actions = request["actions"];
    }
    if (actions.length == 0) {
      Json fallback = Json.emptyObject;
      fallback["action_type"] = "email";
      fallback["target"] = "ops@example.com";
      fallback["enabled"] = true;
      actions ~= fallback;
    }
    return actions;
  }

  private string[] getStringArray(Json objectOrMap, string key) {
    if (!(key in objectOrMap) || !objectOrMap[key].isArray) {
      return [];
    }
    return toLoweredStringArray(objectOrMap[key]);
  }

  private string[] toLoweredStringArray(Json values) {
    string[] result;
    if (!(values.isArray)) {
      return result;
    }
    foreach (item; values.toArray) {
      if (item.isString) {
        result ~= toLower(item.get!string);
      }
    }
    return result;
  }

  private string requiredString(Json request, string key) {
    if (!(key in request) || !request[key].isString) {
      throw new AlertNotificationValidationException(key ~ " is required");
    }
    auto value = request[key].get!string;
    if (value.length == 0) {
      throw new AlertNotificationValidationException(key ~ " cannot be empty");
    }
    return value;
  }

  private Json optionalArray(Json request, string key) {
    if (key in request && request[key].isArray) {
      return request[key];
    }
    return Json.emptyArray;
  }

  private Json optionalObject(Json request, string key) {
    if (key in request && request[key].isObject) {
      return request[key];
    }
    return Json.emptyObject;
  }

}
