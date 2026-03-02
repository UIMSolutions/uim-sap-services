module uim.sap.cia.exceptions;

/// Base exception for all CIA service errors
class CIAException : Exception {
    this(string message) { super(message); }
}

/// Thrown when validation of input data fails
class CIAValidationException : CIAException {
    this(string message) { super(message); }
}

/// Thrown when a requested resource is not found
class CIANotFoundException : CIAException {
    this(string message) { super(message); }
}

/// Thrown when a caller lacks the required role/permission
class CIAAuthorizationException : CIAException {
    this(string message) { super(message); }
}

/// Thrown when service configuration is invalid
class CIAConfigurationException : CIAException {
    this(string message) { super(message); }
}

/// Thrown when a workflow state transition is illegal
class CIAWorkflowStateException : CIAException {
    this(string message) { super(message); }
}

/// Thrown when a task automation step fails
class CIAAutomationException : CIAException {
    this(string message) { super(message); }
}
