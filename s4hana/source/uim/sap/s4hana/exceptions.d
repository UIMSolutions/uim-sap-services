/**
 * Exception types for S/4HANA operations
 */
module uim.sap.s4hana.exceptions;

class SAPS4HANAException : Exception {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
    pure nothrow @safe @nogc {
        super(msg, file, line, next);
    }
}

class SAPS4HANAConfigurationException : SAPS4HANAException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
    pure nothrow @safe @nogc {
        super(msg, file, line, next);
    }
}

class SAPS4HANAConnectionException : SAPS4HANAException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
    pure nothrow @safe @nogc {
        super(msg, file, line, next);
    }
}

class SAPS4HANARequestException : SAPS4HANAException {
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
