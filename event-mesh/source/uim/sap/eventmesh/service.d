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

    return Json.emptyObject
      .set("success", true)
      .set("queue", saved.toJson());
  }

  Json listQueues(UUID tenantId) {
    validateId(tenantId, "Tenant ID");

    auto resources = _store.listQueues(tenantId).map!(q => q.toJson).array;

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

    return Json.emptyObject
      .set("queue", queue.toJson())
      .set("pending_messages", _store.queueDepth(tenantId, queueName));
  }

  Json deleteQueue(UUID tenantId, string queueName) {
    validateId(tenantId, "Tenant ID");
    validateId(queueName, "Queue name");

    if (!_store.deleteQueue(tenantId, queueName)) {
      throw new EVMNotFoundException("Queue", tenantId ~ "/" ~ queueName);
    }

    return Json.emptyObject
      .set("success", true)
      .set("message", "Queue deleted: " ~ queueName);
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

    return Json.emptyObject
      .set("success", true)
      .set("topic", saved.toJson());
  }

  Json listTopics(UUID tenantId) {
    validateId(tenantId, "Tenant ID");

    auto resources = _store.listTopics(tenantId).map!(t => t.toJson).array;

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
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

    return Json.emptyObject
      .set("success", true)
      .set("subscription", saved.toJson());
  }

  Json listSubscriptions(UUID tenantId) {
    validateId(tenantId, "Tenant ID");

    auto resources = _store.listSubscriptions(tenantId).map!(sub => sub.toJson).array;

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
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

    return Json.emptyObject
      .set("success", true)
      .set("message_id", message.messageId)
      .set("topic", topicName)
      .set("routed_to_queues", routedCount)
      .set("message", "Event published successfully");
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
      return Json.emptyObject
        .set("success", true)
        .set("message", Json(null))
        .set("info", "No pending messages in queue");
    }

    return Json.emptyObject
      .set("success", true)
      .set("message", message.toJson());
  }

  Json acknowledgeMessage(UUID tenantId, string queueName, string messageId) {
    validateId(tenantId, "Tenant ID");
    validateId(queueName, "Queue name");
    validateId(messageId, "Message ID");

    if (!_store.acknowledgeMessage(tenantId, queueName, messageId)) {
      throw new EVMNotFoundException("Message", tenantId ~ "/" ~ queueName ~ "/" ~ messageId);
    }

    return Json.emptyObject
      .set("success", true)
      .set("message", "Message acknowledged");
  }

  Json listQueueMessages(UUID tenantId, string queueName) {
    validateId(tenantId, "Tenant ID");
    validateId(queueName, "Queue name");

    auto queue = _store.getQueue(tenantId, queueName);
    if (queue.queueName.length == 0) {
      throw new EVMNotFoundException("Queue", tenantId ~ "/" ~ queueName);
    }

    auto resources = _store.listMessages(tenantId, queueName).map!(msg => msg.toJson).array;

    return Json.emptyObject
      .set("queue_name", queueName)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
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

    return Json.emptyObject
      .set("success", true)
      .set("webhook", saved.toJson());
  }

  Json listWebhooks(UUID tenantId) {
    validateId(tenantId, "Tenant ID");

    auto resources = _store.listWebhooks(tenantId).map!(wh => wh.toJson).array;

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json deleteWebhook(UUID tenantId, string webhookId) {
    validateId(tenantId, "Tenant ID");
    validateId(webhookId, "Webhook ID");

    if (!_store.deleteWebhook(tenantId, webhookId)) {
      throw new EVMNotFoundException("Webhook", tenantId ~ "/" ~ webhookId);
    }

    return Json.emptyObject
      .set("success", true)
      .set("message", "Webhook deleted");
  }

  // --- Dead letter queue ---

  Json listDeadLetters(UUID tenantId, string queueName) {
    validateId(tenantId, "Tenant ID");
    validateId(queueName, "Queue name");

    auto queue = _store.getQueue(tenantId, queueName);
    if (queue.queueName.length == 0) {
      throw new EVMNotFoundException("Queue", tenantId ~ "/" ~ queueName);
    }

    auto resources = _store.listDeadLetters(tenantId, queueName).map!(dl => dl.toJson).array;

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("queue_name", queueName)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
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

    long totalPublished = topics.map!(t => t.messagesPublished).sum;
 
    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("queues", cast(long)queues.length)
      .set("topics", cast(long)topics.length)
      .set("subscriptions", cast(long)subscriptions.length)
      .set("webhooks", cast(long)webhooks.length)
      .set("total_messages", totalMessages)
      .set("total_published", totalPublished)
      .set("pending_messages", totalPending)
      .set("dead_letters", totalDeadLetters);
  }
}
