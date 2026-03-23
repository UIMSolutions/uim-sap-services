module uim.sap.dma.exceptions.validation;

/// Thrown when input validation fails (maps to HTTP 422).
class DMAValidationException : DMAException {
  this(string message) {
    super("Validation failed: " ~ message);
  }
}
