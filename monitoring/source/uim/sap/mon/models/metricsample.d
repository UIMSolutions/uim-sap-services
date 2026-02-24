module uim.sap.mon.models.metricsample;

import uim.sap.mon;

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
struct MONMetricSample {
  string targetType;
  string targetId;
  string metricKind;
  double value;
  string unit;
  SysTime collectedAt;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["target_type"] = targetType;
    payload["target_id"] = targetId;
    payload["metric_kind"] = metricKind;
    payload["value"] = value;
    payload["unit"] = unit;
    payload["collected_at"] = collectedAt.toISOExtString();
    return payload;
  }
}

MONMetricSample metricSample(string targetType, string targetId, string metricKind, double value, string unit) {
  MONMetricSample sample;
  sample.targetType = targetType;
  sample.targetId = targetId;
  sample.metricKind = metricKind;
  sample.value = value;
  sample.unit = unit;
  sample.collectedAt = Clock.currTime();
  return sample;
}
