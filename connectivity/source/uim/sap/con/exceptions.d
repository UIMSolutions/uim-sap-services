module uim.sap.con.exceptions;

class CONException : Exception {
    this(string msg) {
        super(msg);
    }
}

class CONConfigurationException : CONException {
    this(string msg) {
        super(msg);
    }
}

class CONAuthorizationException : CONException {
    this(string msg) {
        super(msg);
    }
}

class CONValidationException : CONException {
    this(string msg) {
        super(msg);
    }
}

class CONNotFoundException : CONException {
    this(string kind, string id) {
        super(kind ~ " not found: " ~ id);
    }
}
