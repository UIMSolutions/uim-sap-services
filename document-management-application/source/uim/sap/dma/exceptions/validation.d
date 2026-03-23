module uim.sap.dma.exceptions.validation;

import uim.sap.dma;

mixin(ShowModule!());

@safe:

/// Thrown when input validation fails (maps to HTTP 422).
class DMAValidationException : DMAException {
  this(string message) {
    super("Validation failed: " ~ message);
  }
}
