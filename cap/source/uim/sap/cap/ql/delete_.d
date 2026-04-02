/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cap.ql.delete_;

import uim.sap.cap.ql.filter;

import std.conv : to;

/// Fluent builder for CQL DELETE queries.
class CqlDelete {
    private string _entity;
    private CqlPredicate[] _predicates;

    this(string entity) {
        _entity = entity;
    }

    /// Entity name to delete from.
    string entity() const { return _entity; }

    /// Active filter predicates.
    CqlPredicate[] predicates() const { return _predicates; }

    /// Add a WHERE predicate.
    CqlDelete where(string field, Op op, string value) {
        _predicates ~= CqlPredicate(field, op, value);
        return this;
    }

    /// Delete a single entity by primary key.
    CqlDelete byId(string id) {
        return where("ID", Op.EQ, id);
    }
}
