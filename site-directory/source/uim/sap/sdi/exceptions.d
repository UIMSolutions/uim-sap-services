module uim.sap.sdi.exceptions;

class SDIException : Exception {
    this(string msg) { super(msg); }
}

class SDIValidationException : SDIException {
    this(string msg) { super(msg); }
}

class SDINotFoundException : SDIException {
    this(string msg) { super(msg); }
}

class SDIAuthorizationException : SDIException {
    this(string msg) { super(msg); }
}

class SDIConfigurationException : SDIException {
    this(string msg) { super(msg); }
}
