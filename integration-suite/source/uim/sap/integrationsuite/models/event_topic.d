/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.integrationsuite.models.event_topic;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

/** 
 * Represents an event topic in the SAP Integration Suite.
 * An event topic is a logical channel for publishing and subscribing to events.
 *
  * Fields:
  * - tenantId: The ID of the tenant that owns this event topic.  
  * - topicId: A unique identifier for the event topic.
  * - topicName: The name of the event topic.
  * - description: A brief description of the event topic.
  * - subscriberCount: The number of subscribers to this event topic.
  * - messagesPublished: The total number of messages published to this event topic.
  * - createdAt: The timestamp when the event topic was created.
  * - updatedAt: The timestamp when the event topic was last updated.
  * 
  * Methods:
  * - toJson(): Converts the event topic instance into a JSON representation.
  * - eventTopicFromJson(UUID tenantId, Json request): Creates a new event topic instance from a JSON request, generating a unique topicId and setting the createdAt and updatedAt timestamps
  * 
  * For more information on event topics and their management, refer to the SAP Integration Suite documentation.
 */
struct INTEventTopic {
  UUID tenantId;
  string topicId;
  string topicName;
  string description;
  long subscriberCount = 0;
  long messagesPublished = 0;
  string createdAt;
  string updatedAt;

  override Json toJson()  {
    return super.toJson()
    .set("tenant_id", tenantId)
    .set("topic_id", topicId)
    .set("topic_name", topicName)
    .set("description", description)
    .set("subscriber_count", subscriberCount)
    .set("messages_published", messagesPublished)
    .set("created_at", createdAt)
    .set("updated_at", updatedAt);
  }
}

INTEventTopic eventTopicFromJson(UUID tenantId, Json request) {
  INTEventTopic t;
  t.tenantId = tenantId;
  t.topicId = randomUUID();

  if ("topic_name" in request && request["topic_name"].isString)
    t.topicName = request["topic_name"].getString;
  if ("description" in request && request["description"].isString)
    t.description = request["description"].getString;

  t.createdAt = Clock.currTime().toINTOExtString();
  t.updatedAt = t.createdAt;
  return t;
}
