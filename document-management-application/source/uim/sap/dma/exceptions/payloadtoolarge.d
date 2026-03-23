module uim.sap.dma.exceptions.payloadtoolarge;

import uim.sap.dma;

mixin(ShowModule!());

@safe:

/// Thrown when the upload exceeds maximum allowed size (maps to HTTP 413).
class DMAPayloadTooLargeException : DMAException {
    this(string message) {
        super("Payload too large: " ~ message);
    }
}