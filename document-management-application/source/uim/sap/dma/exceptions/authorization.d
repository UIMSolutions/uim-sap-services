module uim.sap.dma.exceptions.authorization;
/// Thrown when authorization fails (maps to HTTP 401).
class DMAAuthorizationException : DMAException {
    this(string message) {
        super("Unauthorized: " ~ message);
    }
}
