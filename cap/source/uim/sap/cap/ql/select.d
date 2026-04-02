/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cap.ql.select;

import uim.sap.cap.ql.filter;

import std.conv : to;

/// Fluent builder for CQL SELECT queries.
class CqlSelect {
    private string _entity;
    private string[] _columns;
    private CqlPredicate[] _predicates;
    private string[] _orderByFields;
    private bool[] _orderByDesc;
    private int _limit = -1;
    private int _offset = 0;
    private bool _count = false;
    private bool _one = false;

    this(string entity) {
        _entity = entity;
    }

    /// Entity name being queried.
    string entity() const { return _entity; }

    /// Columns to project. Empty means all columns.
    string[] columns() const { return _columns; }

    /// Active filter predicates.
    CqlPredicate[] predicates() const { return _predicates; }

    /// Order-by field names.
    string[] orderByFields() const { return _orderByFields; }

    /// Whether each order-by field is descending.
    bool[] orderByDescending() const { return _orderByDesc; }

    /// Row limit (-1 means unlimited).
    int limit() const { return _limit; }

    /// Row offset.
    int offset() const { return _offset; }

    /// Whether to include a total count.
    bool countRequested() const { return _count; }

    /// Whether this is a single-entity read (byId).
    bool isSingleRead() const { return _one; }

    /// Specify columns to return (projection).
    CqlSelect col(string[] cols...) {
        _columns ~= cols;
        return this;
    }

    /// Add a WHERE predicate with a string value.
    CqlSelect where(string field, Op op, string value) {
        _predicates ~= CqlPredicate(field, op, value);
        return this;
    }

    /// Add a WHERE predicate with an integer value.
    CqlSelect where(string field, Op op, int value) {
        _predicates ~= CqlPredicate(field, op, value.to!string);
        return this;
    }

    /// Add a WHERE predicate with a long value.
    CqlSelect where(string field, Op op, long value) {
        _predicates ~= CqlPredicate(field, op, value.to!string);
        return this;
    }

    /// Add a WHERE predicate with a double value.
    CqlSelect where(string field, Op op, double value) {
        _predicates ~= CqlPredicate(field, op, value.to!string);
        return this;
    }

    /// Add an equality predicate (shorthand).
    CqlSelect where(string field, string value) {
        return where(field, Op.EQ, value);
    }

    /// Read a single entity by its primary key value.
    CqlSelect byId(string id) {
        _one = true;
        return where("ID", Op.EQ, id);
    }

    /// Set the maximum number of rows to return.
    CqlSelect limit_(int n) {
        _limit = n;
        return this;
    }

    /// Set the row offset (for pagination).
    CqlSelect offset_(int n) {
        _offset = n;
        return this;
    }

    /// Add an ORDER BY clause.
    CqlSelect orderBy(string field, bool desc = false) {
        _orderByFields ~= field;
        _orderByDesc ~= desc;
        return this;
    }

    /// Request a total count alongside results.
    CqlSelect withCount() {
        _count = true;
        return this;
    }
}
