/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.datasphere.models.glossaryterm;

import uim.sap.datasphere;

mixin(ShowModule!());

@safe:

/**
  * DATGlossaryTerm represents a term in the data glossary, including its definition and metadata.
  * It is used to facilitate data governance and understanding across the organization.
  *
  * Fields:
  * - tenantId: The ID of the tenant to which this glossary term belongs.
  * - termId: A unique identifier for the glossary term.
  * - term: The name of the glossary term.    
  * - definition: A detailed definition of the glossary term.
  * - updatedAt: The timestamp of the last update to this glossary term.
  */
struct DATGlossaryTerm {
  UUID tenantId;
  string termId;
  string term;
  string definition;
  SysTime updatedAt;

  override Json toJson()  {
    Json info = super.toJson;
    payload["tenant_id"] = tenantId;
    payload["term_id"] = termId;
    payload["term"] = term;
    payload["definition"] = definition;
    payload["updated_at"] = updatedAt.toISOExtString();
    return payload;
  }
}
