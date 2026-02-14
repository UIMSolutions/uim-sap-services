/**
 * Exception handling for SAP HANA Cloud operations
 * 
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.exceptions;

import std.exception : Exception;

/**
 * Base exception for all SAP HANA related errors
 */
class SAPException : Exception {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable nextInChain = null) pure nothrow @nogc @safe {
        super(msg, file, line, nextInChain);
    }
}

/**
 * Exception thrown when authentication fails
 */
class SAPAuthenticationException : SAPException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable nextInChain = null) pure nothrow @nogc @safe {
        super(msg, file, line, nextInChain);
    }
}

/**
 * Exception thrown when a connection error occurs
 */
class SAPConnectionException : SAPException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable nextInChain = null) pure nothrow @nogc @safe {
        super(msg, file, line, nextInChain);
    }
}

/**
 * Exception thrown when a query fails
 */
class SAPQueryException : SAPException {
    int errorCode;
    
    this(string msg, int code = 0, string file = __FILE__, size_t line = __LINE__, Throwable nextInChain = null) pure nothrow @safe {
        super(msg, file, line, nextInChain);
        this.errorCode = code;
    }
}

/**
 * Exception thrown when response parsing fails
 */
class SAPResponseException : SAPException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable nextInChain = null) pure nothrow @nogc @safe {
        super(msg, file, line, nextInChain);
    }
}

/**
 * Exception thrown when configuration is invalid
 */
class SAPConfigurationException : SAPException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable nextInChain = null) pure nothrow @nogc @safe {
        super(msg, file, line, nextInChain);
    }
}
