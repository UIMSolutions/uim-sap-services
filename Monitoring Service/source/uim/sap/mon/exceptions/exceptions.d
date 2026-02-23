module uim.sap.mon.exceptions.exceptions;

class MONException : Exception {
    this(string msg) {
        super(msg);
    }
}

class MONConfigurationException : MONException {
    this(string msg) {
        super(msg);
    }
}

class MONAuthorizationException : MONException {
    this(string msg) {
        super(msg);
    }
}

class MONValidationException : MONException {
    this(string msg) {
        super(msg);
    }
}

class MONNotFoundException : MONException {
    this(string kind, string id) {
        super(kind ~ " not found: " ~ id);
    }
}
