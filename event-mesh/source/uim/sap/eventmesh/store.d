module uim.sap.eventmesh.store;

import core.sync.mutex : Mutex;

import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:


class EMStore : SAPStore {
    private EMQueue[string] _queues;
    private EMTopic[string] _topics;
    private EMSubscription[string] _subscriptions;
    private EMWebhook[string] _webhooks;

    private EMMessage[][string] _messagesByQueue;
    private EMDeadLetter[][string] _deadLettersByQueue;

    private Mutex _lock;

    this() {
        _lock = new Mutex;
    }

    // --- Queue operations ---

    EMQueue upsertQueue(EMQueue queue) {
        synchronized (_lock) {
            auto key = queueKey(queue.tenantId, queue.queueName);
            if (auto existing = key in _queues) {
                queue.createdAt = existing.createdAt;
                queue.messageCount = existing.messageCount;
                queue.deadLetterCount = existing.deadLetterCount;
            }
            _queues[key] = queue;
            return queue;
        }
    }

    EMQueue getQueue(string tenantId, string queueName) {
        synchronized (_lock) {
            auto key = queueKey(tenantId, queueName);
            if (auto value = key in _queues) {
                return *value;
            }
        }
        return EMQueue.init;
    }

    EMQueue[] listQueues(string tenantId) {
        EMQueue[] list;
        synchronized (_lock) {
            foreach (key, queue; _queues) {
                if (belongsToTenant(key, tenantId)) {
                    list ~= queue;
                }
            }
        }
        return list;
    }

    bool deleteQueue(string tenantId, string queueName) {
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

    EMTopic upsertTopic(EMTopic topic) {
        synchronized (_lock) {
            auto key = topicKey(topic.tenantId, topic.topicName);
            if (auto existing = key in _topics) {
                topic.createdAt = existing.createdAt;
                topic.subscriberCount = existing.subscriberCount;
                topic.messagesPublished = existing.messagesPublished;
            }
            _topics[key] = topic;
            return topic;
        }
    }

    EMTopic getTopic(string tenantId, string topicName) {
        synchronized (_lock) {
            auto key = topicKey(tenantId, topicName);
            if (auto value = key in _topics) {
                return *value;
            }
        }
        return EMTopic.init;
    }

    EMTopic[] listTopics(string tenantId) {
        EMTopic[] list;
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

    EMSubscription addSubscription(EMSubscription subscription) {
        synchronized (_lock) {
            _subscriptions[subscription.subscriptionId] = subscription;

            // Increment subscriber count on topic
            auto tKey = topicKey(subscription.tenantId, subscription.topicName);
            if (auto topic = tKey in _topics) {
                ++topic.subscriberCount;
                topic.updatedAt = Clock.currTime().toISOExtString();
            }

            return subscription;
        }
    }

    EMSubscription[] listSubscriptions(string tenantId) {
        EMSubscription[] list;
        synchronized (_lock) {
            foreach (_, sub; _subscriptions) {
                if (sub.tenantId == tenantId) {
                    list ~= sub;
                }
            }
        }
        return list;
    }

    EMSubscription[] subscriptionsForTopic(string tenantId, string topicName) {
        EMSubscription[] list;
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

    void enqueueMessage(string tenantId, string queueName, EMMessage message) {
        synchronized (_lock) {
            auto key = queueKey(tenantId, queueName);
            message.queueName = queueName;
            _messagesByQueue[key] ~= message;

            if (auto queue = key in _queues) {
                ++queue.messageCount;
                queue.updatedAt = Clock.currTime().toISOExtString();
            }
        }
    }

    EMMessage[] listMessages(string tenantId, string queueName) {
        synchronized (_lock) {
            auto key = queueKey(tenantId, queueName);
            if (auto items = key in _messagesByQueue) {
                return (*items).dup;
            }
        }
        return [];
    }

    EMMessage consumeMessage(string tenantId, string queueName) {
        synchronized (_lock) {
            auto key = queueKey(tenantId, queueName);
            if (auto items = key in _messagesByQueue) {
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
        return EMMessage.init;
    }

    bool acknowledgeMessage(string tenantId, string queueName, string messageId) {
        synchronized (_lock) {
            auto key = queueKey(tenantId, queueName);
            if (auto items = key in _messagesByQueue) {
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

    long queueDepth(string tenantId, string queueName) {
        synchronized (_lock) {
            auto key = queueKey(tenantId, queueName);
            if (auto items = key in _messagesByQueue) {
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

    EMWebhook upsertWebhook(EMWebhook webhook) {
        synchronized (_lock) {
            _webhooks[webhook.webhookId] = webhook;
            return webhook;
        }
    }

    EMWebhook[] listWebhooks(string tenantId) {
        EMWebhook[] list;
        synchronized (_lock) {
            foreach (_, wh; _webhooks) {
                if (wh.tenantId == tenantId) {
                    list ~= wh;
                }
            }
        }
        return list;
    }

    EMWebhook[] webhooksForQueue(string tenantId, string queueName) {
        EMWebhook[] list;
        synchronized (_lock) {
            foreach (_, wh; _webhooks) {
                if (wh.tenantId == tenantId && wh.queueName == queueName && wh.active) {
                    list ~= wh;
                }
            }
        }
        return list;
    }

    bool deleteWebhook(string tenantId, string webhookId) {
        synchronized (_lock) {
            if (auto wh = webhookId in _webhooks) {
                if (wh.tenantId == tenantId) {
                    _webhooks.remove(webhookId);
                    return true;
                }
            }
        }
        return false;
    }

    // --- Dead letter operations ---

    void appendDeadLetter(EMDeadLetter dl) {
        synchronized (_lock) {
            auto key = queueKey(dl.tenantId, dl.queueName);
            _deadLettersByQueue[key] ~= dl;

            if (auto queue = key in _queues) {
                ++queue.deadLetterCount;
            }
        }
    }

    EMDeadLetter[] listDeadLetters(string tenantId, string queueName) {
        synchronized (_lock) {
            auto key = queueKey(tenantId, queueName);
            if (auto items = key in _deadLettersByQueue) {
                return (*items).dup;
            }
        }
        return [];
    }

    // --- Key helpers ---

    private string queueKey(string tenantId, string queueName) {
        return tenantId ~ ":queue:" ~ queueName;
    }

    private string topicKey(string tenantId, string topicName) {
        return tenantId ~ ":topic:" ~ topicName;
    }

    private bool belongsToTenant(string key, string tenantId) {
        return key.length > tenantId.length + 1
            && key[0 .. tenantId.length] == tenantId
            && key[tenantId.length] == ':';
    }
}
