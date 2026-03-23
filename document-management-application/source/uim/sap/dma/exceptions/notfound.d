module uim.sap.dma.exceptions.notfound;

import uim.sap.dma;

mixin(ShowModule!());

@safe:

/// Thrown when a resource is not found (maps to HTTP 404).
class DMANotFoundException : DMAException {
    this(string resource, string identifier) {
        super(resource ~ " not found: " ~ identifier);
    }
}
