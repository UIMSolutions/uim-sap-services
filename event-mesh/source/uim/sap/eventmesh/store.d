module uim.sap.eventmesh.store;

import core.sync.mutex : Mutex;

import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:

class EVMStore : SAPStore {
  protected EVMQueue[string] _queues;
  protected EVMTopic[string] _topics;
  protected EVMSubscription[string] _subscriptions;
  protected EVMWebhook[string] _webhooks;
  protected EVMMessage[][string] _messagesByQueue;
  protected EVMDeadLetter[][string] _deadLettersByQueue;
  protected Mutex _lock;

  this() {
    _lock = new Mutex;
  }

  // --- Queue operations ---

  EVMQueue upsertQueue(EVMQueue queue) {
    synchronized (_lock) {
      auto key = queueKey(queue.tenantId, queue.queueName);
      if (key in _queues) {
        auto existing = _queues[key];
        queue.createdAt = existing.createdAt;
        queue.messageCount = existing.messageCount;
        queue.deadLetterCount = existing.deadLetterCount;
      }
      _queues[key] = queue;
      return queue;
    }
    return null;
  }

  EVMQueue getQueue(UUID tenantId, string queueName) {
    synchronized (_lock) {
      return _queues.get(queueKey(tenantId, queueName), null); 
    }
    return null;
  }

  EVMQueue[] listQueues(UUID tenantId) {
    synchronized (_lock) {
      return _queues.filter!(kv => belongsToTenant(kv.key, tenantId)).byValue.array;
    }
    return null;
  }

  bool deleteQueue(UUID tenantId, string queueName) {
    synchronized (_lock) {
      auto key = queueKey(tenantId, queueName);
      if (key in _queues) {
        _queues.remove(key);
        _messagesByQueue.remove(key);
        _deadLettersByQueue.remove(key);
        return true;
      }
    }
    return false;
  }

  // --- Topic operations ---

  EVMTopic upsertTopic(EVMTopic topic) {
    synchronized (_lock) {
      auto key = topicKey(topic.tenantId, topic.topicName);
      if (key in _topics) {
        auto existing = _topics[key];
        topic.createdAt = existing.createdAt;
        topic.subscriberCount = existing.subscriberCount;
        topic.messagesPublished = existing.messagesPublished;
      }
      _topics[key] = topic;
      return topic;
    }
  }

  EVMTopic getTopic(UUID tenantId, string topicName) {
    synchronized (_lock) {
      auto key = topicKey(tenantId, topicName);
      if (key in _topics) {
        auto value = _topics[key];
        return value;
      }
    }
    return null;
  }

  EVMTopic[] listTopics(UUID tenantId) {
    EVMTopic[] list;
    synchronized (_lock) {
      foreach (key, topic; _topics) {
        if (belongsToTenant(key, tenantId)) {
          list ~= topic;
        }
      }
    }
    return list;
  }

  // --- Subscription operations ---

  EVMSubscription addSubscription(EVMSubscription subscription) {
    synchronized (_lock) {
      _subscriptions[subscription.subscriptionId] = subscription;

      // Increment subscriber count on topic
      auto tKey = topicKey(subscription.tenantId, subscription.topicName);
      if (tKey in _topics) {
        auto topic = _topics[tKey];
        ++topic.subscriberCount;
        topic.updatedAt = Clock.currTime();
      }

      return subscription;
    }
  }

  EVMSubscription[] listSubscriptions(UUID tenantId) {
    synchronized (_lock) {
      EVMSubscription[] list;
      foreach (_, sub; _subscriptions) {
        if (sub.tenantId == tenantId) {
          list ~= sub;
        }
      }
    }
    return null;
  }

  EVMSubscription[] subscriptionsForTopic(UUID tenantId, string topicName) {
    EVMSubscription[] list;
    synchronized (_lock) {
      foreach (_, sub; _subscriptions) {
        if (sub.tenantId == tenantId && sub.topicName == topicName && sub.active) {
          list ~= sub;
        }
      }
    }
    return list;
  }

  // --- Message operations ---

  void enqueueMessage(UUID tenantId, string queueName, EVMMessage message) {
    synchronized (_lock) {
      auto key = queueKey(tenantId, queueName);
      message.queueName = queueName;
      _messagesByQueue[key] ~= message;

      if (key in _queues) {
        auto queue = _queues[key];
        ++queue.messageCount;
        queue.updatedAt = Clock.currTime();
      }
    }
  }

  EVMMessage[] listMessages(UUID tenantId, string queueName) {
    synchronized (_lock) {
      auto key = queueKey(tenantId, queueName);
      if (key in _messagesByQueue) {
        auto items = _messagesByQueue[key];
        return items.dup;
      }
    }
    return null;
  }

  EVMMessage consumeMessage(UUID tenantId, string queueName) {
    synchronized (_lock) {
      auto key = queueKey(tenantId, queueName);
      if (key in _messagesByQueue) {
        auto items = _messagesByQueue[key];
        // Find first pending message
        foreach (ref msg; *items) {
          if (msg.status == "pending") {
            msg.status = "consumed";
            msg.consumedAt = Clock.currTime().toISOExtString();
            return msg;
          }
        }
      }
    }
    return EVMMessage.init;
  }

  bool acknowledgeMessage(UUID tenantId, string queueName, string messageId) {
    synchronized (_lock) {
      auto key = queueKey(tenantId, queueName);
      if (key in _messagesByQueue) {
        auto items = _messagesByQueue[key];
        foreach (ref msg; *items) {
          if (msg.messageId == messageId) {
            msg.status = "acknowledged";
            return true;
          }
        }
      }
    }
    return false;
  }

  long queueDepth(UUID tenantId, string queueName) {
    synchronized (_lock) {
      auto key = queueKey(tenantId, queueName);
      if (key in _messagesByQueue) {
        auto items = _messagesByQueue[key];
        long count = 0;
        foreach (ref msg; *items) {
          if (msg.status == "pending") {
            ++count;
          }
        }
        return count;
      }
    }
    return 0;
  }

  // --- Webhook operations ---

  EVMWebhook upsertWebhook(EVMWebhook webhook) {
    synchronized (_lock) {
      _webhooks[webhook.webhookId] = webhook;
      return webhook;
    }
  }

  EVMWebhook[] listWebhooks(UUID tenantId) {
    EVMWebhook[] list;
    synchronized (_lock) {
      foreach (_, wh; _webhooks) {
        if (wh.tenantId == tenantId) {
          list ~= wh;
        }
      }
    }
    return list;
  }

  EVMWebhook[] webhooksForQueue(UUID tenantId, string queueName) {
    EVMWebhook[] list;
    synchronized (_lock) {
      foreach (_, wh; _webhooks) {
        if (wh.tenantId == tenantId && wh.queueName == queueName && wh.active) {
          list ~= wh;
        }
      }
    }
    return list;
  }

  bool deleteWebhook(UUID tenantId, string webhookId) {
    synchronized (_lock) {
      if (webhookId in _webhooks) {
        auto wh = _webhooks[webhookId];
        if (wh.tenantId == tenantId) {
          _webhooks.remove(webhookId);
          return true;
        }
      }
    }
    return false;
  }

  // --- Dead letter operations ---

  void appendDeadLetter(EVMDeadLetter dl) {
    synchronized (_lock) {
      auto key = queueKey(dl.tenantId, dl.queueName);
      _deadLettersByQueue[key] ~= dl;

      if (key in _queues) {
        auto queue = _queues[key];
        ++queue.deadLetterCount;
      }
    }
  }

  EVMDeadLetter[] listDeadLetters(UUID tenantId, string queueName) {
    synchronized (_lock) {
      auto key = queueKey(tenantId, queueName);
      if (key in _deadLettersByQueue) {
        auto items = _deadLettersByQueue[key];
        return items.dup;
      }
    }
    return null;
  }

  // --- Key helpers ---

  private string queueKey(UUID tenantId, string queueName) {
    return tenantId ~ ":queue:" ~ queueName;
  }

  private string topicKey(UUID tenantId, string topicName) {
    return tenantId ~ ":topic:" ~ topicName;
  }

  private bool belongsToTenant(string key, UUID tenantId) {
    return key.length > tenantId.length + 1
      && key[0 .. tenantId.length] == tenantId
      && key[tenantId.length] == ':';
  }
}
