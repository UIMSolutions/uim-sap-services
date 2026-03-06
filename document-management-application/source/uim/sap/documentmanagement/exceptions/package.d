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
class DOCException : SAPException {
    this(string message) {
        super(message);
    }
}

/// Thrown when input validation fails (maps to HTTP 422).
class DOCValidationException : DOCException {
    this(string message) {
        super("Validation failed: " ~ message);
    }
}

/// Thrown when a resource is not found (maps to HTTP 404).
class DOCNotFoundException : DOCException {
    this(string resource, string identifier) {
        super(resource ~ " not found: " ~ identifier);
    }
}

/// Thrown when authorization fails (maps to HTTP 401).
class DOCAuthorizationException : DOCException {
    this(string message) {
        super("Unauthorized: " ~ message);
    }
}

/// Thrown on configuration problems (startup failure).
class DOCConfigurationException : DOCException {
    this(string message) {
        super("Configuration error: " ~ message);
    }
}

/// Thrown when a conflict occurs (maps to HTTP 409), e.g. checked-out document.
class DOCConflictException : DOCException {
    this(string message) {
        super("Conflict: " ~ message);
    }
}

/// Thrown when the upload exceeds maximum allowed size (maps to HTTP 413).
class DOCPayloadTooLargeException : DOCException {
    this(string message) {
        super("Payload too large: " ~ message);
    }
}
