module uim.sap.s4hana.exceptions.exception;

class S4HANAException : Exception {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
    pure nothrow @safe @nogc {
        super(msg, file, line, next);
    }
}