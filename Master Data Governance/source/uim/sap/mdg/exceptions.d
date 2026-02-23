module uim.sap.mdg.exceptions;

class MDGException : Exception {
    this(string msg) {
        super(msg);
    }
}

class MDGConfigurationException : MDGException {
    this(string msg) {
        super(msg);
    }
}

class MDGAuthorizationException : MDGException {
    this(string msg) {
        super(msg);
    }
}

class MDGValidationException : MDGException {
    this(string msg) {
        super(msg);
    }
}

class MDGNotFoundException : MDGException {
    this(string kind, string id) {
        super(kind ~ " not found: " ~ id);
    }
}
