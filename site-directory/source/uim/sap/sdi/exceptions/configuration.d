module uim.sap.sdi.exceptions.configuration;

import uim.sap.sdi;

mixin(ShowModule!());

@safe:

class SDIConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(SDI) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(SDI) " ~ message, file, line, next);
  }
}
///
unittest {
  SDIConfigurationException ex1 = new SDIConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (SDI) Test message");

  SDIConfigurationException ex2 = new SDIConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (SDI) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}