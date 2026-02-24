module uim.sap.agentry.exceptions;

class AgentryException : Exception {
    this(string message) {
        super(message);
    }
}

class AgentryValidationException : AgentryException {
    this(string message) {
        super("Validation failed: " ~ message);
    }
}

class AgentryNotFoundException : AgentryException {
    this(string resource, string identifier) {
        super(resource ~ " not found: " ~ identifier);
    }
}

class AgentryAuthorizationException : AgentryException {
    this(string message) {
        super("Unauthorized: " ~ message);
    }
}

class AgentryConfigurationException : AgentryException {
    this(string message) {
        super("Configuration error: " ~ message);
    }
}
