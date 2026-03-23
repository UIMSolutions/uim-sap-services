module uim.sap.dma.exceptions.authorization;

import uim.sap.dma;

mixin(ShowModule!());

@safe:

/// Thrown when authorization fails (maps to HTTP 401).
class DMAAuthorizationException : DMAException {
    this(string message) {
        super("Unauthorized: " ~ message);
    }
}
