module uim.sap.bas.exceptions;

class BASException : Exception {
    this(string message) {
        super(message);
    }
}

class BASConfigurationException : BASException {
    this(string message) {
        super(message);
    }
}

class BASValidationException : BASException {
    this(string message) {
        super(message);
    }
}

class BASNotFoundException : BASException {
    this(string message) {
        super(message);
    }
}

class BASAuthorizationException : BASException {
    this(string message) {
        super(message);
    }
}
