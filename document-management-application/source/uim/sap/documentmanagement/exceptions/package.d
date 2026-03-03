module uim.sap.documentmanagement.exceptions;

public {
    import uim.framework.exceptions;

    import uim.sap.dpi.exceptions.authorization;
    import uim.sap.dpi.exceptions.configuration;
    import uim.sap.dpi.exceptions.exception;
    import uim.sap.dpi.exceptions.notfound;
    import uim.sap.dpi.exceptions.validation;
}

/// Base exception for all Document Management errors.
class DocumentManagementException : Exception {
    this(string message) {
        super(message);
    }
}

/// Thrown when input validation fails (maps to HTTP 422).
class DocumentManagementValidationException : DocumentManagementException {
    this(string message) {
        super("Validation failed: " ~ message);
    }
}

/// Thrown when a resource is not found (maps to HTTP 404).
class DocumentManagementNotFoundException : DocumentManagementException {
    this(string resource, string identifier) {
        super(resource ~ " not found: " ~ identifier);
    }
}

/// Thrown when authorization fails (maps to HTTP 401).
class DocumentManagementAuthorizationException : DocumentManagementException {
    this(string message) {
        super("Unauthorized: " ~ message);
    }
}

/// Thrown on configuration problems (startup failure).
class DocumentManagementConfigurationException : DocumentManagementException {
    this(string message) {
        super("Configuration error: " ~ message);
    }
}

/// Thrown when a conflict occurs (maps to HTTP 409), e.g. checked-out document.
class DocumentManagementConflictException : DocumentManagementException {
    this(string message) {
        super("Conflict: " ~ message);
    }
}

/// Thrown when the upload exceeds maximum allowed size (maps to HTTP 413).
class DocumentManagementPayloadTooLargeException : DocumentManagementException {
    this(string message) {
        super("Payload too large: " ~ message);
    }
}
