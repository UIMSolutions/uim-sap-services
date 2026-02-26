module uim.sap.agentry.exceptions.validation;

class AgentryValidationException : AgentryException {
    this(string message) {
        super("Validation failed: " ~ message);
    }
}