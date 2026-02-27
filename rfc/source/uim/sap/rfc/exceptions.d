/**
 * Exception handling for RFC adapter
 *
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.rfc.exceptions;

class SAPRFCException : Exception {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
    pure nothrow @safe @nogc {
        super(msg, file, line, next);
    }
}

class SAPRFCConfigurationException : SAPRFCException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
    pure nothrow @safe @nogc {
        super(msg, file, line, next);
    }
}

class SAPRFCConnectionException : SAPRFCException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
    pure nothrow @safe @nogc {
        super(msg, file, line, next);
    }
}

class SAPRFCInvocationException : SAPRFCException {
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
