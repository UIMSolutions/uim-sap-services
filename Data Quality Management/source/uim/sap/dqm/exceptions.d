module uim.sap.dqm.exceptions;

class DQMException : Exception {
    this(string msg) { super(msg); }
}

class DQMConfigurationException : DQMException {
    this(string msg) { super(msg); }
}

class DQMAuthorizationException : DQMException {
    this(string msg) { super(msg); }
}

class DQMValidationException : DQMException {
    this(string msg) { super(msg); }
}

class DQMNotFoundException : DQMException {
    this(string kind, string id) { super(kind ~ " not found: " ~ id); }
}
