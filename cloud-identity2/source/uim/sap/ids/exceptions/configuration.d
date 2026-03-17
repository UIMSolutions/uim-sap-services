module uim.sap.ids.exceptions.configuration;

import uim.sap.ids;
@safe:

/**
 * Exception thrown when configuration is invalid
 */
class IdentityConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(IDT) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(IDT) " ~ message, file, line, next);
  }
}
///
unittest {
  IdentityConfigurationException ex1 = new IdentityConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (IDT) Test message");

  IdentityConfigurationException ex2 = new IdentityConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (IDT) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}