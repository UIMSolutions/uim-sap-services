module uim.sap.sci.exceptions.exception;

class SCIException : Exception {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}