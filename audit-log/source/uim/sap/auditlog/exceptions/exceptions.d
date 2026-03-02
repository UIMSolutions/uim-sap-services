module uim.sap.auditlog.exceptions;

class AuditLogException : Exception {
    this(string message) {
        super(message);
    }
}

class AuditLogValidationException : AuditLogException {
    this(string message) {
        super("Validation failed: " ~ message);
    }
}

class AuditLogNotFoundException : AuditLogException {
    this(string resource, string identifier) {
        super(resource ~ " not found: " ~ identifier);
    }
}

class AuditLogAuthorizationException : AuditLogException {
    this(string message) {
        super("Unauthorized: " ~ message);
    }
}

class AuditLogConfigurationException : AuditLogException {
    this(string message) {
        super("Configuration error: " ~ message);
    }
}
