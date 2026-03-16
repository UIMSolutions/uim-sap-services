module uim.sap.cia.exceptions.configuration;

class CIAConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(CIA) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(CIA) " ~ message, file, line, next);
  }
}
///
unittest {
  CIAConfigurationException ex1 = new CIAConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (CIA) Test message");

  CIAConfigurationException ex2 = new CIAConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (CIA) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}