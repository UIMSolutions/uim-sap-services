/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.mon.models.jmxcheck;

import uim.sap.mon;

@safe:

/**
  * Represents a JMX check configuration for monitoring.
  *
  * Fields:
  * - checkId: A unique identifier for the JMX check.
  * - targetId: The identifier of the target being monitored (e.g., a service
  *   or application).
  * - mbean: The JMX MBean name to query.
  * - attribute: The specific attribute of the MBean to check.
  * - comparator: The comparison operator to use (e.g., ">", "<", "==").
  * - threshold: The threshold value to compare against the MBean attribute value.
  * - enabled: A boolean indicating whether this JMX check is currently enabled.
  * - createdAt: The timestamp when this JMX check configuration was created.
  * 
  * This struct is used to define the configuration for a JMX check that can be performed on a target service or application. It includes all necessary information to execute the check and evaluate the
  * results against a specified threshold using a comparison operator.
  * The toJson method allows for easy serialization of the JMX check configuration into a JSON format, which can be useful for API responses or storage.
  * Example usage:
  *   MONJMXCheck jmxCheck;
  *   jmxCheck.checkId = "check-123";
  *   jmxCheck.targetId = "service-abc";
  *   jmxCheck.mbean = "java.lang:type=Memory";
  *   jmxCheck.attribute = "HeapMemoryUsage";
  *   jmxCheck.comparator = ">";
  *   jmxCheck.threshold = 80.0;
  *   jmxCheck.enabled = true;
  *   jmxCheck.createdAt = Clock.currTime();
  */
struct MONJMXCheck {
  string checkId;
  string targetId;
  string mbean;
  string attribute;
  string comparator;
  double threshold;
  bool enabled;
  SysTime createdAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["check_id"] = checkId;
    payload["target_id"] = targetId;
    payload["mbean"] = mbean;
    payload["attribute"] = attribute;
    payload["comparator"] = comparator;
    payload["threshold"] = threshold;
    payload["enabled"] = enabled;
    payload["created_at"] = createdAt.toISOExtString();
    return payload;
  }
}
