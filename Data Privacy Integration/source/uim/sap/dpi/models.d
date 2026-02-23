module uim.sap.dpi.models;

import std.datetime : Clock, SysTime;
import std.uuid : randomUUID;

import vibe.data.json : Json;

string createId() {
    return randomUUID().toString();
}

struct DPIRetentionRule {
    string tenantId;
    string ruleId;
    string dataCategory;
    int retentionDays;
    bool active;
    SysTime updatedAt;

    Json toJson() const {
        Json payload = Json.emptyObject;
        payload["tenant_id"] = tenantId;
        payload["rule_id"] = ruleId;
        payload["data_category"] = dataCategory;
        payload["retention_days"] = retentionDays;
        payload["active"] = active;
        payload["updated_at"] = updatedAt.toISOExtString();
        return payload;
    }
}

struct DPIPersonalDataRecord {
    string tenantId;
    string recordId;
    string subjectId;
    string category;
    string source;
    Json payload;
    SysTime createdAt;
    SysTime updatedAt;
    bool deleted;

    Json toJson() const {
        Json result = Json.emptyObject;
        result["tenant_id"] = tenantId;
        result["record_id"] = recordId;
        result["subject_id"] = subjectId;
        result["category"] = category;
        result["source"] = source;
        result["payload"] = payload;
        result["created_at"] = createdAt.toISOExtString();
        result["updated_at"] = updatedAt.toISOExtString();
        result["deleted"] = deleted;
        return result;
    }
}

struct DPIExport {
    string tenantId;
    string exportId;
    string subjectId;
    Json records;
    SysTime createdAt;

    Json toJson() const {
        Json result = Json.emptyObject;
        result["tenant_id"] = tenantId;
        result["export_id"] = exportId;
        result["subject_id"] = subjectId;
        result["records"] = records;
        result["created_at"] = createdAt.toISOExtString();
        return result;
    }
}

DPIPersonalDataRecord recordFromJson(string tenantId, Json request) {
    DPIPersonalDataRecord record;
    record.tenantId = tenantId;
    record.recordId = createId();
    record.createdAt = Clock.currTime();
    record.updatedAt = record.createdAt;
    record.payload = Json.emptyObject;
    record.deleted = false;

    if ("record_id" in request && request["record_id"].type == Json.Type.string) record.recordId = request["record_id"].get!string;
    if ("subject_id" in request && request["subject_id"].type == Json.Type.string) record.subjectId = request["subject_id"].get!string;
    if ("category" in request && request["category"].type == Json.Type.string) record.category = request["category"].get!string;
    if ("source" in request && request["source"].type == Json.Type.string) record.source = request["source"].get!string;
    if ("payload" in request && request["payload"].type == Json.Type.object) record.payload = request["payload"];

    return record;
}
