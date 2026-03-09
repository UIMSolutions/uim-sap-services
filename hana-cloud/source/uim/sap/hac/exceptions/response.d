module uim.sap.hac.exceptions.response;

/**
 * Exception thrown when response parsing fails
 */
class SAPResponseException : SAPException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable nextInChain = null) pure nothrow @nogc @safe {
        super(msg, file, line, nextInChain);
    }
}
