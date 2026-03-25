/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.alertnotification.store;

import core.sync.mutex : Mutex;

import uim.sap.alertnotification;

mixin(ShowModule!());

@safe:

class AlertNotificationStore : SAPStore {
  protected AlertEvent[string] _alerts;
  protected AlertSubscription[string] _subscriptions;
  protected AlertDelivery[string] _deliveries;
  protected Mutex _lock;

  this() {
    _lock = new Mutex;
  }

  AlertEvent appendAlert(AlertEvent eventItem) {
    synchronized (_lock) {
      _alerts[scopedKey(eventItem.tenantId, "alert", eventItem.alertId)] = eventItem;
      return eventItem;
    }
  }

  AlertEvent[] listAlerts(UUID tenantId) {
    AlertEvent[] values;
    synchronized (_lock) {
      foreach (key, value; _alerts) {
        if (belongsTo(key, tenantId)) {
          values ~= value;
        }
      }
    }
    return values;
  }

  AlertSubscription upsertSubscription(AlertSubscription subscription) {
    synchronized (_lock) {
      auto key = scopedKey(subscription.tenantId, "subscription", subscription.subscriptionId);
      if (auto existing = key in _subscriptions) {
        subscription.createdAt = existing.createdAt;
      }
      _subscriptions[key] = subscription;
      return subscription;
    }
  }

  AlertSubscription getSubscription(UUID tenantId, string subscriptionId) {
    synchronized (_lock) {
      auto key = scopedKey(tenantId, "subscription", subscriptionId);
      if (auto value = key in _subscriptions) {
        return *value;
      }
    }
    return AlertSubscription.init;
  }

  bool deleteSubscription(UUID tenantId, string subscriptionId) {
    synchronized (_lock) {
      auto key = scopedKey(tenantId, "subscription", subscriptionId);
      if ((key in _subscriptions) is null) {
        return false;
      }
      _subscriptions.remove(key);
      return true;
    }
  }

  AlertSubscription[] listSubscriptions(UUID tenantId) {
    AlertSubscription[] values;
    synchronized (_lock) {
      foreach (key, value; _subscriptions) {
        if (belongsTo(key, tenantId)) {
          values ~= value;
        }
      }
    }
    return values;
  }

  AlertDelivery appendDelivery(AlertDelivery delivery) {
    synchronized (_lock) {
      _deliveries[scopedKey(delivery.tenantId, "delivery", delivery.deliveryId)] = delivery;
      return delivery;
    }
  }

  AlertDelivery[] listDeliveries(UUID tenantId) {
    AlertDelivery[] values;
    synchronized (_lock) {
      foreach (key, value; _deliveries) {
        if (belongsTo(key, tenantId)) {
          values ~= value;
        }
      }
    }
    return values;
  }

  private string scopedKey(UUID tenantId, string scopePart, string id) {
    return tenantId ~ ":" ~ scopePart ~ ":" ~ id;
  }

  private bool belongsTo(string key, UUID tenantId) {
    return key.length > tenantId.length + 1 && key[0 .. tenantId.length] == tenantId && key[tenantId
      .length] == ':';
  }
}
