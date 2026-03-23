module uim.sap.documentmanagement.exceptions.conflict;
/// Thrown when a conflict occurs (maps to HTTP 409), e.g. checked-out document.
class DMAConflictException : DMAException {
    this(string message) {
        super("Conflict: " ~ message);
    }
}