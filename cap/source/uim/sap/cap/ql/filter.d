/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cap.ql.filter;

/// Comparison operators for CQL query predicates.
enum Op {
    EQ,           /// Equal (=)
    NE,           /// Not equal (!=)
    GT,           /// Greater than (>)
    GE,           /// Greater than or equal (>=)
    LT,           /// Less than (<)
    LE,           /// Less than or equal (<=)
    LIKE,         /// Pattern match
    IN,           /// In set
    BETWEEN,      /// Between two values
    IS_NULL,      /// Is null
    IS_NOT_NULL   /// Is not null
}

/// A single predicate in a CQL WHERE clause.
struct CqlPredicate {
    string field;
    Op op = Op.EQ;
    string value;      /// String representation of the comparison value
    string value2;     /// Second value for BETWEEN
}
