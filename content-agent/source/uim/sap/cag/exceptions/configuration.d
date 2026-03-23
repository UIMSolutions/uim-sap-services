module uim.sap.cag.exceptions.configuration;

import uim.sap.cag;

mixin(ShowModule!());

@safe:

class CAGConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(CAG) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(CAG) " ~ message, file, line, next);
  }
}
///
unittest {
  CAGConfigurationException ex1 = new CAGConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (CAG) Test message");

  CAGConfigurationException ex2 = new CAGConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (CAG) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}