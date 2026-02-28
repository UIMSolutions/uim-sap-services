module uim.sap.aem.exceptions.configuration;

class AEMConfigurationException : AEMException {
    this(string message) {
        super("Configuration error: " ~ message);
    }
}
