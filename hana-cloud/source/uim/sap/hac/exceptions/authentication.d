module uim.sap.HANA Cloud.exceptions.authentication;

/**
 * Exception thrown when authentication fails
 */
class SAPAuthenticationException : SAPException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable nextInChain = null) pure nothrow @nogc @safe {
        super(msg, file, line, nextInChain);
    }
}
