module uim.sap.documentmanagement.exceptions.exception;
/// Base exception for all Document Management errors.
class DMAException : SAPException {
    this(string message) {
        super(message);
    }
}