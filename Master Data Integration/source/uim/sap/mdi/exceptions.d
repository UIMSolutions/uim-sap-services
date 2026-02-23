module uim.sap.mdi.exceptions;

class MDIException : Exception {
    this(string msg) { super(msg); }
}

class MDIConfigurationException : MDIException {
    this(string msg) { super(msg); }
}

class MDIAuthorizationException : MDIException {
    this(string msg) { super(msg); }
}

class MDIValidationException : MDIException {
    this(string msg) { super(msg); }
}

class MDINotFoundException : MDIException {
    this(string kind, string id) { super(kind ~ " not found: " ~ id); }
}
