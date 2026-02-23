module uim.sap.dpi.exceptions;

class DPIException : Exception {
    this(string msg) { super(msg); }
}

class DPIConfigurationException : DPIException {
    this(string msg) { super(msg); }
}

class DPIAuthorizationException : DPIException {
    this(string msg) { super(msg); }
}

class DPIValidationException : DPIException {
    this(string msg) { super(msg); }
}

class DPINotFoundException : DPIException {
    this(string kind, string id) { super(kind ~ " not found: " ~ id); }
}
