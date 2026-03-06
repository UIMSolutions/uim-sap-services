module uim.sap.atm.exceptions.exceptions;

class ATMException : SAPException {
    this(string message) {
        super(message);
    }
}

class ATMValidationException : ATMException {
    this(string message) {
        super("Validation failed: " ~ message);
    }
}

class ATMNotFoundException : ATMException {
    this(string resource, string identifier) {
        super(resource ~ " not found: " ~ identifier);
    }
}

class ATMAuthorizationException : ATMException {
    this(string message) {
        super("Unauthorized: " ~ message);
    }
}

class ATMConfigurationException : ATMException {
    this(string message) {
        super("Configuration error: " ~ message);
    }
}
