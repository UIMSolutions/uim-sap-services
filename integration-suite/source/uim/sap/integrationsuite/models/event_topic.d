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
  * - eventTopicFromJson(string tenantId, Json request): Creates a new event topic instance from a JSON request, generating a unique topicId and setting the createdAt and updatedAt timestamps
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
    Json j = Json.emptyObject;
    j["tenant_id"] = tenantId;
    j["topic_id"] = topicId;
    j["topic_name"] = topicName;
    j["description"] = description;
    j["subscriber_count"] = subscriberCount;
    j["messages_published"] = messagesPublished;
    j["created_at"] = createdAt;
    j["updated_at"] = updatedAt;
    return j;
  }
}

INTEventTopic eventTopicFromJson(string tenantId, Json request) {
  INTEventTopic t;
  t.tenantId = UUID(tenantId);
  t.topicId = randomUUID().toString();

  if ("topic_name" in request && request["topic_name"].isString)
    t.topicName = request["topic_name"].get!string;
  if ("description" in request && request["description"].isString)
    t.description = request["description"].get!string;

  t.createdAt = Clock.currTime().toINTOExtString();
  t.updatedAt = t.createdAt;
  return t;
}
