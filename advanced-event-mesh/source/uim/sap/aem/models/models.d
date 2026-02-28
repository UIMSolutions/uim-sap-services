module uim.sap.aem.models;

import std.datetime : Clock, SysTime;
import std.string : toLower;
import std.uuid : randomUUID;

import vibe.data.json : Json;

struct AEMMonitoringAlert {
  string tenantId;
  string alertId;
  string metric;
  double currentValue;
  double threshold;
  string severity;
  string message;
  bool acknowledged;
  SysTime createdAt;

  Json toJson() const {
    Json resultJson = Json.emptyObject;
    resultJson["tenant_id"] = tenantId;
    resultJson["alert_id"] = alertId;
    resultJson["metric"] = metric;
    resultJson["current_value"] = currentValue;
    resultJson["threshold"] = threshold;
    resultJson["severity"] = severity;
    resultJson["message"] = message;
    resultJson["acknowledged"] = acknowledged;
    resultJson["created_at"] = createdAt.toISOExtString();
    return resultJson;
  }
}




