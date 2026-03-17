module uim.sap.fiori.exceptions.configuration;

import uim.sap.fiori;
@safe:
class FioriConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(FIO) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(FIO) " ~ message, file, line, next);
  }
}
///
unittest {
  FioriConfigurationException ex1 = new FioriConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (FIO) Test message");

  FioriConfigurationException ex2 = new FioriConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (FIO) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}