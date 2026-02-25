/**
 * Exceptions for BUH service
 */
module uim.sap.buh.exceptions;

class BUHException : Exception {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}

class BUHConfigurationException : BUHException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}

class BUHValidationException : BUHException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}

class BUHNotFoundException : BUHException {
    this(string entityType, string id, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(entityType ~ " not found: " ~ id, file, line, next);
    }
}

class BUHAuthorizationException : BUHException {
    this(string msg = "Unauthorized", string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}
