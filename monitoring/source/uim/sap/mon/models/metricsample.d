/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.mon.models.metricsample;

import uim.sap.mon;

mixin(ShowModule!());

@safe:

/**
  * Represents a single metric sample collected for monitoring purposes.
  * Each sample contains information about the target of the metric, the kind of metric, its value, and when it was collected.
  *
  * Fields:
  * - targetType: The type of the target this metric is associated with (e.g., "service", "endpoint").
  * - targetId: The unique identifier of the target this metric is associated with.
  * - metricKind: The kind of metric being collected (e.g., "response_time", "error_rate").
  * - value: The numeric value of the metric sample.
  * - unit: The unit of measurement for the metric value (e.g., "milliseconds", "percent").
  * - collectedAt: The timestamp when this metric sample was collected.
  */
class MONMetricSample : SAPEntity {
  mixin(SAPEntityTemplate!MONMetricSample);

  string targetType;
  UUID targetId;
  string metricKind;
  double value;
  string unit;
  SysTime collectedAt;

  override Json toJson()  {
    return super.toJson
    .set("target_type", targetType)
    .set("target_id", targetId)
    .set("metric_kind", metricKind)
    .set("value", value)
    .set("unit", unit)
    .set("collected_at", collectedAt.toISOExtString());
  }

static MONMetricSample metricSample(string targetType, string targetId, string metricKind, double value, string unit) {
  MONMetricSample sample = new MONMetricSample();
  sample.targetType = targetType;
  sample.targetId = targetId;
  sample.metricKind = metricKind;
  sample.value = value;
  sample.unit = unit;
  sample.collectedAt = Clock.currTime();
  return sample;
}

}

