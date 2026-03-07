module uim.sap.documentmanagement.exceptions.payloadtoolarge;


/// Thrown when the upload exceeds maximum allowed size (maps to HTTP 413).
class DMAPayloadTooLargeException : DMAException {
    this(string message) {
        super("Payload too large: " ~ message);
    }
}