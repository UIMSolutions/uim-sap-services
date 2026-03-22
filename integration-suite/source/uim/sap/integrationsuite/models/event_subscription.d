/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.integrationsuite.models.event_subscription;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

/**
  * Represents an event subscription in the SAP Integration Suite.
  * This model captures the details of a subscription to a specific event topic, including the callback URL and delivery mode.
  *
  * Fields:
  * - tenantId: The ID of the tenant that owns this subscription.
  * - subscriptionId: A unique identifier for the subscription.
  * - topicName: The name of the event topic to which this subscription is subscribed.
  * - callbackUrl: The URL to which events will be delivered for this subscription.
  * - deliveryMode: The mode of event delivery (e.g., push or pull).  
  * - active: Indicates whether the subscription is currently active.
  * - deliveredCount: The number of events successfully delivered to the callback URL.
  * - failedCount: The number of events that failed to be delivered to the callback URL.
  * - createdAt: The timestamp when the subscription was created.
  * - updatedAt: The timestamp when the subscription was last updated.
  * 
  * Methods:
  * - toJson(): Converts the subscription instance into a JSON representation.
  * - eventSubscriptionFromJson(UUID tenantId, Json request): Creates a new subscription instance from a JSON request, generating a unique subscriptionId and setting the createdAt and updatedAt timestamps. 
  * For more information on event subscriptions and their management, refer to the SAP Integration Suite documentation.
  */
struct INTEventSubscription {
  UUID tenantId;
  UUID subscriptionId;
  string topicName;
  string callbackUrl;
  string deliveryMode = "push"; // push | pull
  bool active = true;
  long deliveredCount = 0;
  long failedCount = 0;
  string createdAt;
  string updatedAt;

  override Json toJson()  {
    return super.toJson()
    j["tenant_id"] = tenantId;
    j["subscription_id"] = subscriptionId;
    j["topic_name"] = topicName;
    j["callback_url"] = callbackUrl;
    j["delivery_mode"] = deliveryMode;
    j["active"] = active;
    j["delivered_count"] = deliveredCount;
    j["failed_count"] = failedCount;
    j["created_at"] = createdAt;
    j["updated_at"] = updatedAt;
    return j;
  }
}

INTEventSubscription eventSubscriptionFromJson(UUID tenantId, Json request) {
  INTEventSubscription s;
  s.tenantId = UUID(tenantId);
  s.subscriptionId = randomUUID().toString();

  if ("topic_name" in request && request["topic_name"].isString)
    s.topicName = request["topic_name"].get!string;
  if ("callback_url" in request && request["callback_url"].isString)
    s.callbackUrl = request["callback_url"].get!string;
  if ("delivery_mode" in request && request["delivery_mode"].isString)
    s.deliveryMode = request["delivery_mode"].get!string;

  s.createdAt = Clock.currTime().toINTOExtString();
  s.updatedAt = s.createdAt;
  return s;
}
