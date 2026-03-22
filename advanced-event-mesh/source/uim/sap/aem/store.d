/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.aem.store;

import core.sync.mutex : Mutex;

import uim.sap.aem;

mixin(ShowModule!());

@safe:

class AEMStore : SAPStore {
  private AEMBrokerService[string] _brokers;
  private AEMEventMesh[string] _meshes;
  private AEMEDAComponent[string] _components;
  private AEMNotificationRule[string] _notifications;

  private AEMSubscription[][string] _subscriptionsByTenant;
  private AEMTopicEvent[][string] _eventsByTopicKey;
  private AEMMonitoringAlert[][string] _alertsByTenant;

  private Mutex _lock;

  this() {
    _lock = new Mutex;
  }

  AEMBrokerService upsertBroker(AEMBrokerService broker) {
    synchronized (_lock) {
      auto key = brokerKey(broker.tenantId, broker.brokerServiceId);
      if (auto existing = key in _brokers) {
        broker.createdAt = existing.createdAt;
        broker.connectedClients = existing.connectedClients;
        broker.eventsPublished = existing.eventsPublished;
      }
      _brokers[key] = broker;
      return broker;
    }
  }

  AEMBrokerService getBroker(UUID tenantId, string brokerServiceId) {
    synchronized (_lock) {
      auto key = brokerKey(tenantId, brokerServiceId);
      if (auto value = key in _brokers) {
        return *value;
      }
    }
    return new AEMBrokerService;
  }

  AEMBrokerService[] listBrokers(UUID tenantId) {
    AEMBrokerService[] list;
    synchronized (_lock) {
      foreach (key, broker; _brokers) {
        if (belongsToTenant(key, tenantId)) {
          list ~= broker;
        }
      }
    }
    return list;
  }

  AEMEventMesh upsertMesh(AEMEventMesh mesh) {
    synchronized (_lock) {
      auto key = meshKey(mesh.tenantId, mesh.meshId);
      if (auto existing = key in _meshes) {
        mesh.createdAt = existing.createdAt;
      }
      _meshes[key] = mesh;
      return mesh;
    }
  }

  AEMEventMesh getMesh(UUID tenantId, string meshId) {
    synchronized (_lock) {
      auto key = meshKey(tenantId, meshId);
      if (auto value = key in _meshes) {
        return *value;
      }
    }
    return new AEMEventMesh;
  }

  AEMEventMesh[] listMeshes(UUID tenantId) {
    AEMEventMesh[] list;
    synchronized (_lock) {
      foreach (key, mesh; _meshes) {
        if (belongsToTenant(key, tenantId)) {
          list ~= mesh;
        }
      }
    }
    return list;
  }

  AEMEDAComponent upsertComponent(AEMEDAComponent component) {
    synchronized (_lock) {
      auto key = componentKey(component.tenantId, component.componentId);
      _components[key] = component;
      return component;
    }
  }

  AEMEDAComponent getComponent(UUID tenantId, string componentId) {
    synchronized (_lock) {
      auto key = componentKey(tenantId, componentId);
      if (auto value = key in _components) {
        return *value;
      }
    }
    return new AEMEDAComponent;
  }

  AEMEDAComponent[] listComponents(UUID tenantId) {
    AEMEDAComponent[] list;
    synchronized (_lock) {
      foreach (key, component; _components) {
        if (belongsToTenant(key, tenantId)) {
          list ~= component;
        }
      }
    }
    return list;
  }

  AEMSubscription addSubscription(AEMSubscription subscription) {
    synchronized (_lock) {
      _subscriptionsByTenant[subscription.tenantId] ~= subscription;
      return subscription;
    }
  }

  AEMSubscription[] listSubscriptions(UUID tenantId) {
    synchronized (_lock) {
      if (auto subscriptions = tenantId in _subscriptionsByTenant) {
        return subscriptions.dup;
      }
    }
    return null;
  }

  AEMTopicEvent appendEvent(AEMTopicEvent eventItem) {
    synchronized (_lock) {
      auto key = topicKey(eventItem.tenantId, eventItem.meshId, eventItem.topic);
      _eventsByTopicKey[key] ~= eventItem;
      return eventItem;
    }
  }

  AEMTopicEvent[] listTopicEvents(UUID tenantId, string meshId, string topic) {
    synchronized (_lock) {
      auto key = topicKey(tenantId, meshId, topic);
      if (auto items = key in _eventsByTopicKey) {
        return (*items).dup;
      }
    }
    return null;
  }

  long topicDepth(UUID tenantId, string meshId, string topic) {
    synchronized (_lock) {
      auto key = topicKey(tenantId, meshId, topic);
      if (auto items = key in _eventsByTopicKey) {
        return cast(long)(*items).length;
      }
    }
    return 0;
  }

  AEMNotificationRule upsertNotificationRule(AEMNotificationRule rule) {
    synchronized (_lock) {
      auto key = notificationKey(rule.tenantId, rule.ruleId);
      _notifications[key] = rule;
      return rule;
    }
  }

  AEMNotificationRule[] listNotificationRules(UUID tenantId) {
    AEMNotificationRule[] list;
    synchronized (_lock) {
      foreach (key, rule; _notifications) {
        if (belongsToTenant(key, tenantId)) {
          list ~= rule;
        }
      }
    }
    return list;
  }

  void appendAlert(AEMMonitoringAlert alert) {
    synchronized (_lock) {
      _alertsByTenant[alert.tenantId] ~= alert;
    }
  }

  AEMMonitoringAlert[] listAlerts(UUID tenantId) {
    synchronized (_lock) {
      if (auto alerts = tenantId in _alertsByTenant) {
        return (*alerts).dup;
      }
    }
    return null;
  }

  private string brokerKey(UUID tenantId, string brokerServiceId) {
    return tenantId ~ ":broker:" ~ brokerServiceId;
  }

  private string meshKey(UUID tenantId, string meshId) {
    return tenantId ~ ":mesh:" ~ meshId;
  }

  private string componentKey(UUID tenantId, string componentId) {
    return tenantId ~ ":component:" ~ componentId;
  }

  private string notificationKey(UUID tenantId, string ruleId) {
    return tenantId ~ ":notification:" ~ ruleId;
  }

  private string topicKey(UUID tenantId, string meshId, string topic) {
    return tenantId ~ ":topic:" ~ meshId ~ ":" ~ topic;
  }

  private bool belongsToTenant(string key, UUID tenantId) {
    return key.length > tenantId.length + 1
      && key[0 .. tenantId.length] == tenantId
      && key[tenantId.length] == ':';
  }
}
