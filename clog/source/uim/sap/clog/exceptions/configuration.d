module uim.sap.clog.exceptions.configuration;

class SCIConfigurationException : SCIException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}