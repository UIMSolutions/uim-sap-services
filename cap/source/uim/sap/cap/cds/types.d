/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cap.cds.types;

/// CDS scalar types corresponding to SAP CAP Core Data Services type system.
enum CdsType {
    UUID,
    String,
    Integer,
    Integer64,
    Decimal,
    Double,
    Boolean,
    Date,
    Time,
    DateTime,
    Timestamp,
    Binary,
    LargeBinary,
    LargeString,
    Association,
    Composition
}

/// Annotations for CDS entity fields (mirroring SAP CAP annotations).
enum CdsAnnotation {
    key,
    readonly,
    insertonly,
    mandatory,
    unique,
    virtual_,
    localized
}

/// Metadata definition for a single field (element) in a CDS entity.
struct CdsFieldDef {
    string name;
    CdsType type_ = CdsType.String;
    int length = 0;
    int precision = 0;
    int scale = 0;
    bool isKey = false;
    bool isNotNull = false;
    bool isReadonly = false;
    bool isInsertOnly = false;
    bool isVirtual = false;
    bool isLocalized = false;
    bool isUnique = false;
    string defaultValue;
    string targetEntity;       /// For Association/Composition: target entity name
    string description;
    CdsAnnotation[] annotations;

    bool hasAnnotation(CdsAnnotation ann) const {
        foreach (a; annotations) {
            if (a == ann) return true;
        }
        return false;
    }
}
