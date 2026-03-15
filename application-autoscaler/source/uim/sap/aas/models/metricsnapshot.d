/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.aas.models.metricsnapshot;
import uim.sap.aas;

@safe:
struct AASMetricSnapshot {
    double cpuPercent;
    double memoryPercent;
    double responseTimeMs;
    double throughputRps;
    double[string] custom;

    override Json toJson()  {
        Json payload = Json.emptyObject;
        payload["cpu_percent"] = cpuPercent;
        payload["memory_percent"] = memoryPercent;
        payload["response_time_ms"] = responseTimeMs;
        payload["throughput_rps"] = throughputRps;

        Json customJson = Json.emptyObject;
        foreach (key, value; custom) {
            customJson[key] = value;
        }
        payload["custom"] = customJson;
        return payload;
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
