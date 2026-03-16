module uim.sap.cdc.exceptions.authorization;

import uim.sap.cdc;

mixin(ShowModule!());

@safe:
class CDCAuthorizationException : SAPConfigurationException {
  this(string message) {
    super("(CDC) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(CDC) " ~ message, file, line, next);
  }
}
///
unittest {
  CDCAuthorizationException ex1 = new CDCAuthorizationException("Test message");
  assert(ex1.message == "Configuration error: (CDC) Test message");

  CDCAuthorizationException ex2 = new CDCAuthorizationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (CDC) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}
