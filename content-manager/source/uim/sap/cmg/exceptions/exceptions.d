module uim.sap.cmg.exceptions;

class CMGException : Exception {
    this(string msg) { super(msg); }
}

class CMGValidationException : CMGException {
    this(string msg) { super(msg); }
}

class CMGNotFoundException : CMGException {
    this(string msg) { super(msg); }
}

class CMGAuthorizationException : CMGException {
    this(string msg) { super(msg); }
}

class CMGConfigurationException : CMGException {
    this(string msg) { super(msg); }
}
