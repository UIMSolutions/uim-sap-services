/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cap.ql.update;

import uim.sap.cap.ql.filter;
import uim.sap.service;

import std.conv : to;

/// Fluent builder for CQL UPDATE queries.
class CqlUpdate {
    private string _entity;
    private Json _data;
    private CqlPredicate[] _predicates;

    this(string entity) {
        _entity = entity;
        _data = Json.emptyObject;
    }

    /// Entity name to update.
    string entity() const { return _entity; }

    /// The data fields to set.
    Json data() { return _data; }

    /// Active filter predicates.
    CqlPredicate[] predicates() const { return _predicates; }

    /// Set a string field value.
    CqlUpdate set(string field, string value) {
        _data[field] = Json(value);
        return this;
    }

    /// Set an integer field value.
    CqlUpdate set(string field, int value) {
        _data[field] = Json(value);
        return this;
    }

    /// Set a long field value.
    CqlUpdate set(string field, long value) {
        _data[field] = Json(value);
        return this;
    }

    /// Set a double field value.
    CqlUpdate set(string field, double value) {
        _data[field] = Json(value);
        return this;
    }

    /// Set a boolean field value.
    CqlUpdate set(string field, bool value) {
        _data[field] = Json(value);
        return this;
    }

    /// Set a JSON field value.
    CqlUpdate set(string field, Json value) {
        _data[field] = value;
        return this;
    }

    /// Set all fields from a JSON object.
    CqlUpdate data_(Json d) {
        _data = d;
        return this;
    }

    /// Add a WHERE predicate.
    CqlUpdate where(string field, Op op, string value) {
        _predicates ~= CqlPredicate(field, op, value);
        return this;
    }

    /// Update a single entity by primary key.
    CqlUpdate byId(string id) {
        return where("ID", Op.EQ, id);
    }
}
