module uim.sap.aem.exceptions;

class AEMException : Exception {
    this(string message) {
        super(message);
    }
}

class AEMValidationException : AEMException {
    this(string message) {
        super("Validation failed: " ~ message);
    }
}

class AEMNotFoundException : AEMException {
    this(string resource, string identifier) {
        super(resource ~ " not found: " ~ identifier);
    }
}

class AEMAuthorizationException : AEMException {
    this(string message) {
        super("Unauthorized: " ~ message);
    }
}

class AEMConfigurationException : AEMException {
    this(string message) {
        super("Configuration error: " ~ message);
    }
}
