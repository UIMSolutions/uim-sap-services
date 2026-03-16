module uim.sap.cre.exceptions.configuration;

import uim.sap.cre;

mixin(ShowModule!());

@safe:
class CREConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(CRE) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(CRE) " ~ message, file, line, next);
  }
}
///
unittest {
  CREConfigurationException ex1 = new CREConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (CRE) Test message");

  CREConfigurationException ex2 = new CREConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (CRE) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}