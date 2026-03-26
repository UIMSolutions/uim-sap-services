/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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
class DPIPersonalDataRecord : SAPTenantObject {
  mixin(SAPObjectTemplate!DPIPersonalDataRecord);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("record_id" in request && request["record_id"].isString){
      record.recordId = UUID(request["record_id"].get!string);}
      else {
        record.recordId = randomUUID;
      }

    if ("subject_id" in request && request["subject_id"].isString)
      record.subjectId = UUID(request["subject_id"].get!string);

    category = initData.getString("category", "");
    source = initData.getString("source", "");
    payload = initData.getObject("payload", Json.emptyObject);
    deleted = initData.getBool("deleted", false);


    if ("created_at" in initData && initData["created_at"].isString) {
      record.createdAt = initData["created_at"].get!string;
    } else {
      record.createdAt = Clock.currTime();
    }

    if ("updated_at" in initData && initData["updated_at"].isString) {
      record.updatedAt = initData["updated_at"].get!string;
    } else {    
      record.updatedAt = record.createdAt;
    }

    return true;
  }

  UUID recordId;
  UUID subjectId;
  string category;
  string source;
  Json payload;
  bool deleted;

  override Json toJson() {
    return super.toJson
      .set("record_id", recordId)
      .set("subject_id", subjectId)
      .set("category", category)
      .set("source", source)
      .set("payload", payload)
      .set("deleted", deleted);
  }

  DPIPersonalDataRecord opCall(UUID tenantId, Json request) {
    DPIPersonalDataRecord record = new DPIPersonalDataRecord(request);
    record.tenantId = tenantId;

    return record;
  }
}
