module uim.sap.cps.exceptions.exceptions;

class CPSException : Exception {
    this(string msg) { super(msg); }
}

class CPSConfigurationException : CPSException {
    this(string msg) { super(msg); }
}

class CPSAuthorizationException : CPSException {
    this(string msg) { super(msg); }
}

class CPSValidationException : CPSException {
    this(string msg) { super(msg); }
}

class CPSNotFoundException : CPSException {
    this(string kind, string id) { super(kind ~ " not found: " ~ id); }
}
