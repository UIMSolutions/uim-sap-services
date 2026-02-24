module uim.sap.smg.exceptions;

class SMGException : Exception {
    this(string msg) {
        super(msg);
    }
}

class SMGValidationException : SMGException {
    this(string msg) {
        super(msg);
    }
}

class SMGNotFoundException : SMGException {
    this(string msg) {
        super(msg);
    }
}

class SMGAuthorizationException : SMGException {
    this(string msg) {
        super(msg);
    }
}

class SMGConfigurationException : SMGException {
    this(string msg) {
        super(msg);
    }
}
