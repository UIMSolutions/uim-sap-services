module uim.sap.art.exceptions.notfound;

class ARTRuntimeProgramNotFoundException : ARTRuntimeException {
    this(string programName, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super("ABAP program not found: " ~ programName, file, line, next);
    }
}