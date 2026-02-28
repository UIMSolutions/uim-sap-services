module uim.sap.cre.exceptions;



class CREConfigurationException : CREException {
    this(string msg) {
        super(msg);
    }
}

class CREAuthorizationException : CREException {
    this(string msg) {
        super(msg);
    }
}

class CREValidationException : CREException {
    this(string msg) {
        super(msg);
    }
}

class CRENotFoundException : CREException {
    this(string kind, string id) {
        super(kind ~ " not found: " ~ id);
    }
}
