module uim.sap.dma.exceptions.configuration;

import uim.sap.dma;

mixin(ShowModule!());

@safe:

/// Thrown on configuration problems (startup failure).
class DMAConfigurationException : DMAException {
    this(string message) {
        super("Configuration error: " ~ message);
    }
}