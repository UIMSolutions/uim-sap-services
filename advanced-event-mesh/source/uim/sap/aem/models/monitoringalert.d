/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.aem.models.monitoringalert;

import uim.sap.aem;

mixin(ShowModule!());

@safe:

/**
  * Represents a monitoring alert in the AEM system.
  * This struct is used to encapsulate all relevant information about an alert,
  * including its severity, message, and associated metric values.
  *
  * The `toJson` method allows for easy serialization of the alert to a JSON format,
  * which can be used for API responses or storage in a database.
  * Fields:
  * - `tenantId`: The ID of the tenant this alert belongs to.
  * - `alertId`: The unique ID of the alert.
  * - `metric`: The name of the metric that triggered the alert.
  * - `currentValue`: The current value of the metric that caused the alert.
  * - `threshold`: The threshold value that was breached to trigger the alert.
  * - `severity`: The severity level of the alert (e.g., "critical", "warning", "info").
  * - `message`: A descriptive message about the alert.
  * - `acknowledged`: A boolean indicating whether the alert has been acknowledged.
  * - `createdAt`: The timestamp of when the alert was created.
  * Methods:
  * - `toJson()`: Converts the alert instance to a JSON object for API responses or storage.
  * Example usage:
  * ```
  * AEMMonitoringAlert alert;
  * alert.tenantId = "tenant123";
  * alert.alertId = "alert456";
  * alert.metric = "cpu_usage";
  * alert.currentValue = 95.5;
  * alert.threshold = 90.0;
  * alert.severity = "critical";
  * alert.message = "CPU usage exceeded threshold";
  * alert.acknowledged = false;
  * alert.createdAt = Clock.currTime();
  * Json alertJson = alert.toJson();
  * ```
  * Note: The `toJson()` method is used to serialize the alert instance into a JSON format that can be returned in API responses or stored in a database. The actual implementation of the `toJson()` method may vary based on the specific requirements of the application and the structure of the
  * JSON payload expected by the API consumers. The fields included in the JSON output can be adjusted as needed to fit the use case, and additional fields can be added to the `AEMMonitoringAlert` struct if necessary to capture more information about the alert or its context.
  */
class AEMMonitoringAlert : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!AEMMonitoringAlert);

  UUID alertId;
  string metric;
  double currentValue;
  double threshold;
  string severity;
  string message;
  bool acknowledged;

  override override Json toJson()  {
    Json resultJson = super.toJson();
    resultJson["alert_id"] = alertId;
    resultJson["metric"] = metric;
    resultJson["current_value"] = currentValue;
    resultJson["threshold"] = threshold;
    resultJson["severity"] = severity;
    resultJson["message"] = message;
    resultJson["acknowledged"] = acknowledged;
    return resultJson;
  }
}




