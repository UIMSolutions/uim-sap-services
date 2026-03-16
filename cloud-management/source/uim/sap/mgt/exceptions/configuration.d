module uim.sap.mgt.exceptions.configuration;

import uim.sap.mgt;

mixin(ShowModule!());

@safe:

/**
  * This file defines the MGTConfigurationException class, which is used to represent exceptions related to configuration issues in the Management module.
  * It extends the MGTException class, allowing it to be used in a consistent way with other exceptions in the module.
  *
  * Example usage:
  * try {
  *     // Code that may throw a configuration exception
  * } catch (MGTConfigurationException e) {
  *     // Handle configuration error
  * }
  */
class MGTConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(MGT) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(MGT) " ~ message, file, line, next);
  }
}
///
unittest {
  MGTConfigurationException ex1 = new MGTConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (MGT) Test message");

  MGTConfigurationException ex2 = new MGTConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (MGT) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}