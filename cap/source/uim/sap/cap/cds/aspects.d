/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cap.cds.aspects;

import uim.sap.cap.cds.entity;
import uim.sap.cap.cds.types;

/// Apply the 'managed' aspect to an entity (free function form).
/// Adds: createdAt, createdBy, modifiedAt, modifiedBy.
CdsEntityDef applyManaged(CdsEntityDef ent) {
    return ent.managed();
}

/// Apply the 'cuid' aspect to an entity (free function form).
/// Adds: UUID key "ID" + managed fields.
CdsEntityDef applyCuid(CdsEntityDef ent) {
    return ent.cuid();
}

/// Apply the 'temporal' aspect to an entity (free function form).
/// Adds: validFrom, validTo timestamps.
CdsEntityDef applyTemporal(CdsEntityDef ent) {
    return ent.temporal();
}

/// Create a standard audit fields set for custom aspects.
CdsFieldDef[] auditFields() {
    CdsFieldDef[] result;

    CdsFieldDef ca;
    ca.name = "createdAt";
    ca.type_ = CdsType.Timestamp;
    ca.isReadonly = true;
    result ~= ca;

    CdsFieldDef cb;
    cb.name = "createdBy";
    cb.type_ = CdsType.String;
    cb.length = 255;
    cb.isReadonly = true;
    result ~= cb;

    CdsFieldDef ma;
    ma.name = "modifiedAt";
    ma.type_ = CdsType.Timestamp;
    ma.isReadonly = true;
    result ~= ma;

    CdsFieldDef mb;
    mb.name = "modifiedBy";
    mb.type_ = CdsType.String;
    mb.length = 255;
    mb.isReadonly = true;
    result ~= mb;

    return result;
}
