module uim.sap.mgt.exceptions.exceptions;

class MGTException : Exception {
    this(string msg) {
        super(msg);
    }
}

class MGTConfigurationException : MGTException {
    this(string msg) {
        super(msg);
    }
}

class MGTAuthorizationException : MGTException {
    this(string msg) {
        super(msg);
    }
}

class MGTUpstreamException : MGTException {
    this(string msg) {
        super(msg);
    }
}
