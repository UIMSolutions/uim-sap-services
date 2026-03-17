module uim.sap.ctm.exceptions.configuration;

import uim.sap.ctm;

module(ShowModule!());

@safe:

class CTMConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(CTM) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(CTM) " ~ message, file, line, next);
  }
}
///
unittest {
  CTMConfigurationException ex1 = new CTMConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (CTM) Test message");

  CTMConfigurationException ex2 = new CTMConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (CTM) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}