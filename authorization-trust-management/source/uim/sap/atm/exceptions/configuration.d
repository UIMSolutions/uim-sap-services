module uim.sap.atm.exceptions.configuration;

import uim.sap.atm;

mixin(ShowModule!());

@safe:

class ATMConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(ATM) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(ATM) " ~ message, file, line, next);
  }
}
///
unittest {
  ATMConfigurationException ex1 = new ATMConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (ATM) Test message");

  ATMConfigurationException ex2 = new ATMConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (ATM) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}