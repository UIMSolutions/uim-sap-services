module uim.sap.tc.exceptions.configuration;


class TCConfigurationException : TCException {
    this(string message, string file = __FILE__, size_t line = __LINE__) {
        super(message, file, line);
    }
}
