module uim.sap.cia.exceptions.exception;

/// Base exception for all CIA service errors
class CIAException : SAPException {
    this(string message) { super(message); }
}
