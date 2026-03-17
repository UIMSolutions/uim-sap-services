module uim.sap.atp.exceptions.configuration;

import uim.sap.atp;

mixin(ShowModule!());

@safe:

class ATPConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(ATP) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(ATP) " ~ message, file, line, next);
  }
}
///
unittest {
  ATPConfigurationException ex1 = new ATPConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (ATP) Test message");

  ATPConfigurationException ex2 = new ATPConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (ATP) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}
