/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cap.ql;

public {
    import uim.sap.cap.ql.filter;
    import uim.sap.cap.ql.select;
    import uim.sap.cap.ql.insert;
    import uim.sap.cap.ql.update;
    import uim.sap.cap.ql.delete_;
}

/// CQL (CDS Query Language) entry point — static factory methods for query builders.
struct CQL {
    /// Create a SELECT query builder.
    static CqlSelect select(string entity) {
        return new CqlSelect(entity);
    }

    /// Create an INSERT query builder.
    static CqlInsert insert(string entity) {
        return new CqlInsert(entity);
    }

    /// Create an UPDATE query builder.
    static CqlUpdate update(string entity) {
        return new CqlUpdate(entity);
    }

    /// Create a DELETE query builder.
    static CqlDelete delete_(string entity) {
        return new CqlDelete(entity);
    }
}
