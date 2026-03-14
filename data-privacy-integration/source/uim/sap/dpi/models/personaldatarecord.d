module uim.sap.dpi.models.personaldatarecord;

import uim.sap.dpi;
@safe:

/**
    * Represents a personal data record associated with a specific subject.
    * Each record contains information about the data category, source, and the actual data payload.
    *
    * Fields:
    * - tenantId: The ID of the tenant this record belongs to.
    * - recordId: A unique identifier for the personal data record.
    * - subjectId: The ID of the subject (individual) this data is about.
    * - category: The category of the personal data (e.g., "customer_data", "employee_data").
    * - source: The source system or application where this data originated from.
    * - payload: The actual personal data stored as a JSON object.
    * - createdAt: The timestamp when this record was created.
    * - updatedAt: The timestamp when this record was last updated.
    * - deleted: A boolean indicating whether this record has been marked as deleted.  
    */
struct DPIPersonalDataRecord {
    string tenantId;
    string recordId;
    string subjectId;
    string category;
    string source;
    Json payload = Json.emptyObject;
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

DPIPersonalDataRecord recordFromJson(string tenantId, Json request) {
    DPIPersonalDataRecord record;
    record.tenantId = tenantId;
    record.recordId = createId();
    record.createdAt = Clock.currTime();
    record.updatedAt = record.createdAt;
    record.payload = Json.emptyObject;
    record.deleted = false;

    if ("record_id" in request && request["record_id"].isString) record.recordId = request["record_id"].get!string;
    if ("subject_id" in request && request["subject_id"].isString) record.subjectId = request["subject_id"].get!string;
    if ("category" in request && request["category"].isString) record.category = request["category"].get!string;
    if ("source" in request && request["source"].isString) record.source = request["source"].get!string;
    if ("payload" in request && request["payload"].isObject) record.payload = request["payload"];

    return record;
}