module uim.sap.hac.exceptions.query;

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
