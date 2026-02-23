module uim.sap.datasphere.exceptions;

class DatasphereException : Exception {
    this(string msg) { super(msg); }
}

class DatasphereConfigurationException : DatasphereException {
    this(string msg) { super(msg); }
}

class DatasphereAuthorizationException : DatasphereException {
    this(string msg) { super(msg); }
}

class DatasphereValidationException : DatasphereException {
    this(string msg) { super(msg); }
}

class DatasphereNotFoundException : DatasphereException {
    this(string kind, string id) { super(kind ~ " not found: " ~ id); }
}
