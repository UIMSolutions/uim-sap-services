module uim.sap.cag.exceptions;

class CAGException : Exception {
    this(string message) {
        super(message);
    }
}

class CAGValidationException : CAGException {
    this(string message) {
        super(message);
    }
}

class CAGNotFoundException : CAGException {
    this(string message) {
        super(message);
    }
}

class CAGAuthorizationException : CAGException {
    this(string message) {
        super(message);
    }
}

class CAGConfigurationException : CAGException {
    this(string message) {
        super(message);
    }
}
