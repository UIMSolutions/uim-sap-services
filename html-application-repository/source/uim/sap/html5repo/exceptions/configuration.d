module uim.sap.har.exceptions.configuration;

class HARConfigurationException : HARException {
  this(string message, string file = __FILE__, size_t line = __LINE__) {
    super(message, file, line);
  }
}
