module uim.sap.sci.exceptions.logvalidation;

class SCILogValidationException : SCIException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}