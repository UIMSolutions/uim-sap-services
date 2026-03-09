module uim.sap.hac.exceptions.connection;

/**
 * Exception thrown when a connection error occurs
 */
class SAPConnectionException : SAPException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable nextInChain = null) pure nothrow @nogc @safe {
        super(msg, file, line, nextInChain);
    }
}
