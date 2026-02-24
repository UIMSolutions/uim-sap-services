/**
 * Exceptions for AAS service
 */
module uim.sap.aas.exceptions;

class AASException : Exception {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}

class AASConfigurationException : AASException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}

class AASValidationException : AASException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}

class AASNotFoundException : AASException {
    this(string entityType, string id, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(entityType ~ " not found: " ~ id, file, line, next);
    }
}

class AASAuthorizationException : AASException {
    this(string msg = "Unauthorized", string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}
