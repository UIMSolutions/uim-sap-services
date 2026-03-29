/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.aas.models.metricsnapshot;
import uim.sap.aas;

@safe:
class AASMetricSnapshot : SAPEntity {
  mixin(SAPEntityTemplate!AASMetricSnapshot);

  double cpuPercent;
  double memoryPercent;
  double responseTimeMs;
  double throughputRps;
  double[string] custom;

  override Json toJson() {
    Json customJson = Json.emptyObject;
    foreach (key, value; custom) {
      customJson[key] = value;
    }

    return super.toJson
      .set("cpu_percent", cpuPercent)
      .set("memory_percent", memoryPercent)
      .set("response_time_ms", responseTimeMs)
      .set("throughput_rps", throughputRps)
      .set("custom", customJson);
  }
}

AASMetricSnapshot metricsFromJson(Json payload) {
  AASMetricSnapshot snapshot;

  double numberValue;
  if (tryGetDouble(payload, "cpu_percent", numberValue)) {
    snapshot.cpuPercent = numberValue;
  }
  if (tryGetDouble(payload, "memory_percent", numberValue)) {
    snapshot.memoryPercent = numberValue;
  }
  if (tryGetDouble(payload, "response_time_ms", numberValue)) {
    snapshot.responseTimeMs = numberValue;
  }
  if (tryGetDouble(payload, "throughput_rps", numberValue)) {
    snapshot.throughputRps = numberValue;
  }

  if ("custom" in payload && payload["custom"].isObject) {
    foreach (key, value; payload["custom"].byKeyValue) {
      try {
        snapshot.custom[key] = value.get!double;
      } catch (Exception) {
      }
    }
  }

  return snapshot;
}
