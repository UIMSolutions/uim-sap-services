/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cap.cds.entity;

import uim.sap.cap.cds.types;

/// Defines a CDS entity with fields, keys, and reusable aspects.
/// Provides a fluent builder API for declaring the data model.
class CdsEntityDef {
    string name;
    string description;
    CdsFieldDef[] fields;

    this(string name) {
        this.name = name;
    }

    this(string name, string description) {
        this.name = name;
        this.description = description;
    }

    /// Add a key field (primary key, not-null by default).
    CdsEntityDef key(string fieldName, CdsType type_ = CdsType.UUID, int length = 0) {
        CdsFieldDef f;
        f.name = fieldName;
        f.type_ = type_;
        f.length = length;
        f.isKey = true;
        f.isNotNull = true;
        f.annotations = [CdsAnnotation.key];
        fields ~= f;
        return this;
    }

    /// Add a regular element (field) with type and optional length.
    CdsEntityDef element(string fieldName, CdsType type_, int length = 0) {
        CdsFieldDef f;
        f.name = fieldName;
        f.type_ = type_;
        f.length = length;
        fields ~= f;
        return this;
    }

    /// Add an element marked as mandatory (not-null).
    CdsEntityDef requiredElement(string fieldName, CdsType type_, int length = 0) {
        CdsFieldDef f;
        f.name = fieldName;
        f.type_ = type_;
        f.length = length;
        f.isNotNull = true;
        f.annotations = [CdsAnnotation.mandatory];
        fields ~= f;
        return this;
    }

    /// Add an association to another entity.
    CdsEntityDef association(string fieldName, string targetEntity) {
        CdsFieldDef f;
        f.name = fieldName;
        f.type_ = CdsType.Association;
        f.targetEntity = targetEntity;
        fields ~= f;
        return this;
    }

    /// Add a composition (owned relationship) to another entity.
    CdsEntityDef composition(string fieldName, string targetEntity) {
        CdsFieldDef f;
        f.name = fieldName;
        f.type_ = CdsType.Composition;
        f.targetEntity = targetEntity;
        fields ~= f;
        return this;
    }

    /// Add a virtual (computed, non-persisted) element.
    CdsEntityDef virtualElement(string fieldName, CdsType type_, int length = 0) {
        CdsFieldDef f;
        f.name = fieldName;
        f.type_ = type_;
        f.length = length;
        f.isVirtual = true;
        f.annotations = [CdsAnnotation.virtual_];
        fields ~= f;
        return this;
    }

    /// Mark an existing field as not-null.
    CdsEntityDef notNull(string fieldName) {
        foreach (ref f; fields) {
            if (f.name == fieldName) {
                f.isNotNull = true;
                break;
            }
        }
        return this;
    }

    /// Apply the 'managed' aspect: createdAt, createdBy, modifiedAt, modifiedBy.
    CdsEntityDef managed() {
        CdsFieldDef ca;
        ca.name = "createdAt";
        ca.type_ = CdsType.Timestamp;
        ca.isReadonly = true;
        ca.annotations = [CdsAnnotation.readonly];
        fields ~= ca;

        CdsFieldDef cb;
        cb.name = "createdBy";
        cb.type_ = CdsType.String;
        cb.length = 255;
        cb.isReadonly = true;
        cb.annotations = [CdsAnnotation.readonly];
        fields ~= cb;

        CdsFieldDef ma;
        ma.name = "modifiedAt";
        ma.type_ = CdsType.Timestamp;
        ma.isReadonly = true;
        ma.annotations = [CdsAnnotation.readonly];
        fields ~= ma;

        CdsFieldDef mb;
        mb.name = "modifiedBy";
        mb.type_ = CdsType.String;
        mb.length = 255;
        mb.isReadonly = true;
        mb.annotations = [CdsAnnotation.readonly];
        fields ~= mb;

        return this;
    }

    /// Apply the 'cuid' aspect: UUID key named "ID" plus managed fields.
    CdsEntityDef cuid() {
        this.key("ID", CdsType.UUID);
        return this.managed();
    }

    /// Apply the 'temporal' aspect: validFrom, validTo timestamps.
    CdsEntityDef temporal() {
        CdsFieldDef vf;
        vf.name = "validFrom";
        vf.type_ = CdsType.Timestamp;
        fields ~= vf;

        CdsFieldDef vt;
        vt.name = "validTo";
        vt.type_ = CdsType.Timestamp;
        fields ~= vt;

        return this;
    }

    /// Return the names of all key fields.
    string[] keyFieldNames() const {
        string[] keys;
        foreach (f; fields) {
            if (f.isKey)
                keys ~= f.name;
        }
        return keys;
    }

    /// Look up a field definition by name. Returns null if not found.
    const(CdsFieldDef)* getField(string fieldName) const {
        foreach (ref f; fields) {
            if (f.name == fieldName)
                return &f;
        }
        return null;
    }

    /// Check whether an element with the given name exists.
    bool hasField(string fieldName) const {
        return getField(fieldName) !is null;
    }
}
