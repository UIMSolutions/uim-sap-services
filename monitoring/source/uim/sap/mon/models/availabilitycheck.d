/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.mon.models.availabilitycheck;

import uim.sap.mon;

@safe:

/**
 * Represents a configuration for an availability check of a service or endpoint.
 * 
  * This struct contains all necessary information to perform periodic checks on the availability of a target service or endpoint.
  * It includes details such as the target type and ID, the endpoint to check, the expected status code, and timing configurations.
  * Fields:
 * - checkId: A unique identifier for this availability check configuration.
 * - targetType: The type of the target being monitored (e.g., "service", "application").
 * - targetId: The unique identifier of the target being monitored.
 * - endpoint: The specific endpoint or URL to check for availability.
 * - intervalSeconds: The interval in seconds at which the availability check should be performed.
 * - timeoutSeconds: The maximum time in seconds to wait for a response before considering the check as failed.
 * - expectedStatus: The HTTP status code that indicates the service is available (e.g., 200).
 * - enabled: A boolean indicating whether this availability check is currently enabled.
 * - createdAt: The timestamp when this availability check configuration was created.
 */
struct MONAvailabilityCheck {
  string checkId;
  string targetType;
  string targetId;
  string endpoint;
  int intervalSeconds;
  int timeoutSeconds;
  int expectedStatus;
  bool enabled;
  SysTime createdAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["check_id"] = checkId;
    payload["target_type"] = targetType;
    payload["target_id"] = targetId;
    payload["endpoint"] = endpoint;
    payload["interval_seconds"] = intervalSeconds;
    payload["timeout_seconds"] = timeoutSeconds;
    payload["expected_status"] = expectedStatus;
    payload["enabled"] = enabled;
    payload["created_at"] = createdAt.toISOExtString();
    return payload;
  }
}
