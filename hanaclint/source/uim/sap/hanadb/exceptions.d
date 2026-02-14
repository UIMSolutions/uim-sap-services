/**
 * Exception types for SAP HANA DB client
 */
module uim.sap.hanadb.exceptions;

class SAPHanaDBException : Exception {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
    pure nothrow @safe @nogc {
        super(msg, file, line, next);
    }
}

class SAPHanaDBConfigurationException : SAPHanaDBException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
    pure nothrow @safe @nogc {
        super(msg, file, line, next);
    }
}

class SAPHanaDBConnectionException : SAPHanaDBException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
    pure nothrow @safe @nogc {
        super(msg, file, line, next);
    }
}

class SAPHanaDBQueryException : SAPHanaDBException {
    int statusCode;

    this(
        string msg,
        int statusCode = 0,
        string file = __FILE__,
        size_t line = __LINE__,
        Throwable next = null
    ) pure nothrow @safe {
        super(msg, file, line, next);
        this.statusCode = statusCode;
    }
}
