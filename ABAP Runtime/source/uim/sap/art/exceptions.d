/**
 * Exceptions for SAP ABAP Runtime (ART)
 */
module uim.sap.art.exceptions;

class SAPABAPRuntimeException : Exception {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}

class SAPABAPRuntimeConfigurationException : SAPABAPRuntimeException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}

class SAPABAPRuntimeProgramNotFoundException : SAPABAPRuntimeException {
    this(string programName, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super("ABAP program not found: " ~ programName, file, line, next);
    }
}

class SAPABAPRuntimeExecutionException : SAPABAPRuntimeException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}

class SAPABAPRuntimeAuthenticationException : SAPABAPRuntimeException {
    this(string msg = "Unauthorized", string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}
