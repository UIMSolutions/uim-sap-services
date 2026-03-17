module uim.sap.bas.exceptions.configuration;

import uim.sap.bas;

mixin(ShowModule!());

@safe:


class BASConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(BAS) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(BAS) " ~ message, file, line, next);
  }
}
///
unittest {
  BASConfigurationException ex1 = new BASConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (BAS) Test message");

  BASConfigurationException ex2 = new BASConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (BAS) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}