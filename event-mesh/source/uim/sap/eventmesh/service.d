module uim.sap.eventmesh.service;

import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:

class EVMService : SAPService {
  mixin(SAPServiceTemplate!EVMService);

  private EVMStore _store;

  this(EVMConfig config) {
    super(config);

    _store = new EVMStore;
  }

  // --- Queue management ---

  Json createQueue(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    auto queue = queueFromJson(tenantId, request);
    if (queue.queueName.length == 0) {
      throw new EVMValidationException("queue_name is required");
    }

    auto existing = _store.getQueue(tenantId, queue.queueName);
    if (existing.queueName.length > 0) {
      throw new EVMValidationException("Queue already exists: " ~ queue.queueName);
    }

    auto saved = _store.upsertQueue(queue);

    Json result = Json.emptyObject;
    result["success"] = true;
    result["queue"] = saved.toJson();
    return result;
  }

  Json listQueues(UUID tenantId) {
    validateId(tenantId, "Tenant ID");

    Json resources = Json.emptyArray;
    foreach (queue; _store.listQueues(tenantId)) {
      resources ~= queue.toJson();
    }

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json getQueue(UUID tenantId, string queueName) {
    validateId(tenantId, "Tenant ID");
    validateId(queueName, "Queue name");

    auto queue = _store.getQueue(tenantId, queueName);
    if (queue.queueName.length == 0) {
      throw new EVMNotFoundException("Queue", tenantId ~ "/" ~ queueName);
    }

    Json result = Json.emptyObject;
    result["queue"] = queue.toJson();
    result["pending_messages"] = _store.queueDepth(tenantId, queueName);
    return result;
  }

  Json deleteQueue(UUID tenantId, string queueName) {
    validateId(tenantId, "Tenant ID");
    validateId(queueName, "Queue name");

    if (!_store.deleteQueue(tenantId, queueName)) {
      throw new EVMNotFoundException("Queue", tenantId ~ "/" ~ queueName);
    }

    Json result = Json.emptyObject;
    result["success"] = true;
    result["message"] = "Queue deleted: " ~ queueName;
    return result;
  }

  // --- Topic management ---

  Json createTopic(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    auto topic = topicFromJson(tenantId, request);
    if (topic.topicName.length == 0) {
      throw new EVMValidationException("topic_name is required");
    }

    auto existing = _store.getTopic(tenantId, topic.topicName);
    if (existing.topicName.length > 0) {
      throw new EVMValidationException("Topic already exists: " ~ topic.topicName);
    }

    auto saved = _store.upsertTopic(topic);

    Json result = Json.emptyObject;
    result["success"] = true;
    result["topic"] = saved.toJson();
    return result;
  }

  Json listTopics(UUID tenantId) {
    validateId(tenantId, "Tenant ID");

    Json resources = Json.emptyArray;
    foreach (topic; _store.listTopics(tenantId)) {
      resources ~= topic.toJson();
    }

    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["resources"] = resources;
    result["total_results"] = cast(long)resources.length;
    return result;
  }

  // --- Subscription management ---

  Json createSubscription(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    auto subscription = subscriptionFromJson(tenantId, request);
    if (subscription.topicName.length == 0) {
      throw new EVMValidationException("topic_name is required");
    }
    if (subscription.queueName.length == 0) {
      throw new EVMValidationException("queue_name is required");
    }

    auto topic = _store.getTopic(tenantId, subscription.topicName);
    if (topic.topicName.length == 0) {
      throw new EVMNotFoundException("Topic", tenantId ~ "/" ~ subscription.topicName);
    }

    auto queue = _store.getQueue(tenantId, subscription.queueName);
    if (queue.queueName.length == 0) {
      throw new EVMNotFoundException("Queue", tenantId ~ "/" ~ subscription.queueName);
    }

    auto saved = _store.addSubscription(subscription);

    Json result = Json.emptyObject;
    result["success"] = true;
    result["subscription"] = saved.toJson();
    return result;
  }

  Json listSubscriptions(UUID tenantId) {
    validateId(tenantId, "Tenant ID");

    Json resources = Json.emptyArray;
    foreach (sub; _store.listSubscriptions(tenantId)) {
      resources ~= sub.toJson();
    }

    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["resources"] = resources;
    result["total_results"] = cast(long)resources.length;
    return result;
  }

  // --- Publish events ---

  Json publishMessage(UUID tenantId, string topicName, Json request) {
    validateId(tenantId, "Tenant ID");
    validateId(topicName, "Topic name");

    auto topic = _store.getTopic(tenantId, topicName);
    if (topic.topicName.length == 0) {
      throw new EVMNotFoundException("Topic", tenantId ~ "/" ~ topicName);
    }

    auto message = messageFromJson(tenantId, topicName, request);

    // Route message to all subscribed queues
    auto subscriptions = _store.subscriptionsForTopic(tenantId, topicName);
    long routedCount = 0;

    foreach (sub; subscriptions) {
      auto queue = _store.getQueue(tenantId, sub.queueName);
      if (queue.queueName.length > 0 && queue.status == "active") {
        auto queuedMsg = message;
        queuedMsg.queueName = sub.queueName;
        _store.enqueueMessage(tenantId, sub.queueName, queuedMsg);
        ++routedCount;
      }
    }

    // Update topic stats
    topic.messagesPublished = topic.messagesPublished + 1;
    topic.updatedAt = Clock.currTime().toISOExtString();
    _store.upsertTopic(topic);

    Json result = Json.emptyObject;
    result["success"] = true;
    result["message_id"] = message.messageId;
    result["topic"] = topicName;
    result["routed_to_queues"] = routedCount;
    result["message"] = "Event published successfully";
    return result;
  }

  // --- Consume events ---

  Json consumeMessage(UUID tenantId, string queueName) {
    validateId(tenantId, "Tenant ID");
    validateId(queueName, "Queue name");

    auto queue = _store.getQueue(tenantId, queueName);
    if (queue.queueName.length == 0) {
      throw new EVMNotFoundException("Queue", tenantId ~ "/" ~ queueName);
    }

    auto message = _store.consumeMessage(tenantId, queueName);
    if (message.messageId.length == 0) {
      Json result = Json.emptyObject;
      result["success"] = true;
      result["message"] = Json(null);
      result["info"] = "No pending messages in queue";
      return result;
    }

    Json result = Json.emptyObject;
    result["success"] = true;
    result["message"] = message.toJson();
    return result;
  }

  Json acknowledgeMessage(UUID tenantId, string queueName, string messageId) {
    validateId(tenantId, "Tenant ID");
    validateId(queueName, "Queue name");
    validateId(messageId, "Message ID");

    if (!_store.acknowledgeMessage(tenantId, queueName, messageId)) {
      throw new EVMNotFoundException("Message", tenantId ~ "/" ~ queueName ~ "/" ~ messageId);
    }

    Json result = Json.emptyObject;
    result["success"] = true;
    result["message"] = "Message acknowledged";
    return result;
  }

  Json listQueueMessages(UUID tenantId, string queueName) {
    validateId(tenantId, "Tenant ID");
    validateId(queueName, "Queue name");

    auto queue = _store.getQueue(tenantId, queueName);
    if (queue.queueName.length == 0) {
      throw new EVMNotFoundException("Queue", tenantId ~ "/" ~ queueName);
    }

    Json resources = Json.emptyArray;
    foreach (msg; _store.listMessages(tenantId, queueName)) {
      resources ~= msg.toJson();
    }

    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["queue_name"] = queueName;
    result["resources"] = resources;
    result["total_results"] = cast(long)resources.length;
    return result;
  }

  // --- Webhook management ---

  Json registerWebhook(UUID tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    auto webhook = webhookFromJson(tenantId, request);
    if (webhook.queueName.length == 0) {
      throw new EVMValidationException("queue_name is required");
    }
    if (webhook.callbackUrl.length == 0) {
      throw new EVMValidationException("callback_url is required");
    }

    auto queue = _store.getQueue(tenantId, webhook.queueName);
    if (queue.queueName.length == 0) {
      throw new EVMNotFoundException("Queue", tenantId ~ "/" ~ webhook.queueName);
    }

    auto saved = _store.upsertWebhook(webhook);

    Json result = Json.emptyObject;
    result["success"] = true;
    result["webhook"] = saved.toJson();
    return result;
  }

  Json listWebhooks(UUID tenantId) {
    validateId(tenantId, "Tenant ID");

    Json resources = Json.emptyArray;
    foreach (wh; _store.listWebhooks(tenantId)) {
      resources ~= wh.toJson();
    }

    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["resources"] = resources;
    result["total_results"] = cast(long)resources.length;
    return result;
  }

  Json deleteWebhook(UUID tenantId, string webhookId) {
    validateId(tenantId, "Tenant ID");
    validateId(webhookId, "Webhook ID");

    if (!_store.deleteWebhook(tenantId, webhookId)) {
      throw new EVMNotFoundException("Webhook", tenantId ~ "/" ~ webhookId);
    }

    Json result = Json.emptyObject;
    result["success"] = true;
    result["message"] = "Webhook deleted";
    return result;
  }

  // --- Dead letter queue ---

  Json listDeadLetters(UUID tenantId, string queueName) {
    validateId(tenantId, "Tenant ID");
    validateId(queueName, "Queue name");

    auto queue = _store.getQueue(tenantId, queueName);
    if (queue.queueName.length == 0) {
      throw new EVMNotFoundException("Queue", tenantId ~ "/" ~ queueName);
    }

    Json resources = Json.emptyArray;
    foreach (dl; _store.listDeadLetters(tenantId, queueName)) {
      resources ~= dl.toJson();
    }

    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["queue_name"] = queueName;
    result["resources"] = resources;
    result["total_results"] = cast(long)resources.length;
    return result;
  }

  // --- Dashboard ---

  Json dashboard(UUID tenantId) {
    validateId(tenantId, "Tenant ID");

    auto queues = _store.listQueues(tenantId);
    auto topics = _store.listTopics(tenantId);
    auto subscriptions = _store.listSubscriptions(tenantId);
    auto webhooks = _store.listWebhooks(tenantId);

    long totalMessages = 0;
    long totalPending = 0;
    long totalDeadLetters = 0;

    foreach (queue; queues) {
      totalMessages += queue.messageCount;
      totalDeadLetters += queue.deadLetterCount;
      totalPending += _store.queueDepth(tenantId, queue.queueName);
    }

    long totalPublished = 0;
    foreach (topic; topics) {
      totalPublished += topic.messagesPublished;
    }

    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["queues"] = cast(long)queues.length;
    result["topics"] = cast(long)topics.length;
    result["subscriptions"] = cast(long)subscriptions.length;
    result["webhooks"] = cast(long)webhooks.length;
    result["total_messages"] = totalMessages;
    result["total_published"] = totalPublished;
    result["pending_messages"] = totalPending;
    result["dead_letters"] = totalDeadLetters;
    return result;
  }
}
