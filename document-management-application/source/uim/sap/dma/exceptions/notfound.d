module uim.sap.dma.exceptions.notfound;

/// Thrown when a resource is not found (maps to HTTP 404).
class DMANotFoundException : DMAException {
    this(string resource, string identifier) {
        super(resource ~ " not found: " ~ identifier);
    }
}
