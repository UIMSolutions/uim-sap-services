module uim.sap.art.exceptions.execution;

class ARTRuntimeExecutionException : ARTRuntimeException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}