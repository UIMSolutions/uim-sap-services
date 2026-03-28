/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.dpi.models.export_;

import uim.sap.dpi;

@safe:

/**
 * Represents an export of personal data records for a specific subject.
 * Each export contains metadata about the export and the actual data records in JSON format.
 *
 * Fields:
 * - tenantId: The ID of the tenant this export belongs to.
 * - exportId: A unique identifier for the export.
 * - subjectId: The ID of the subject (individual) this export is about.
 * - records: A JSON array containing the personal data records included in this export.
 * - createdAt: The timestamp when this export was created.  
 */
class DPIExport : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!DPIExport);

  UUID exportId;
  UUID subjectId;
  Json records;

  override Json toJson()  {
    return super.toJson
    .set("export_id", exportId)
    .set("subject_id", subjectId)
    .set("records", records);
  }
}
