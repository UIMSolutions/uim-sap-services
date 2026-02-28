module uim.sap.cis.exceptions;



class CISConfigurationException : CISException {
    this(string msg) {
        super(msg);
    }
}

class CISAuthorizationException : CISException {
    this(string msg) {
        super(msg);
    }
}

class CISValidationException : CISException {
    this(string msg) {
        super(msg);
    }
}

class CISNotFoundException : CISException {
    this(string kind, string id) {
        super(kind ~ " not found: " ~ id);
    }
}
