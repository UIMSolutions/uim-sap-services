
module uim.sap.hac.exceptions.exception;

/**
 * Base exception for all HANA related errors
 */
class SAPException : SAPException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable nextInChain = null) pure nothrow @nogc @safe {
        super(msg, file, line, nextInChain);
    }
}
