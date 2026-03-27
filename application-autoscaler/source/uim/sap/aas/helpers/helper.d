module uim.sap.aas.helpers.helper;
import uim.sap.aas;

@safe:

AASMetricType metricTypeFromString(string value) {
  switch (value) {
  case "cpu":
    return AASMetricType.cpu;
  case "memory":
    return AASMetricType.memory;
  case "response_time":
    return AASMetricType.responseTime;
  case "throughput":
    return AASMetricType.throughput;
  case "custom":
    return AASMetricType.custom;
  default:
    return AASMetricType.custom;
  }
}

enum AASMetricType {
  cpu,
  memory,
  responseTime,
  throughput,
  custom
}

string metricTypeToString(AASMetricType metricType) {
  final switch (metricType) {
  case AASMetricType.cpu:
    return "cpu";
  case AASMetricType.memory:
    return "memory";
  case AASMetricType.responseTime:
    return "response_time";
  case AASMetricType.throughput:
    return "throughput";
  case AASMetricType.custom:
    return "custom";
  }
}

private bool tryGetString(Json payload, string key, out string value) {
  if (!(key in payload)) {
    return false;
  }
  try {
    value = payload[key].getString;
    return true;
  } catch (Exception) {
    return false;
  }
}

private bool tryGetLong(Json payload, string key, out long value) {
  if (!(key in payload)) {
    return false;
  }
  try {
    value = payload[key].get!long;
    return true;
  } catch (Exception) {
    return false;
  }
}

private bool tryGetDouble(Json payload, string key, out double value) {
  if (!(key in payload)) {
    return false;
  }
  try {
    value = payload[key].get!double;
    return true;
  } catch (Exception) {
    return false;
  }
}
