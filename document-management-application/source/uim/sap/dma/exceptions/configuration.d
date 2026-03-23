module uim.sap.dma.exceptions.configuration;
/// Thrown on configuration problems (startup failure).
class DMAConfigurationException : DMAException {
    this(string message) {
        super("Configuration error: " ~ message);
    }
}