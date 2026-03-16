module uim.sap.cpi.exceptions.configuration;

import uim.sap.cpi;

mixin(ShowModule!());

@safe:

class CPIConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(CPI) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(CPI) " ~ message, file, line, next);
  }
}
///
unittest {
  CPIConfigurationException ex1 = new CPIConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (CPI) Test message");

  CPIConfigurationException ex2 = new CPIConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (CPI) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}