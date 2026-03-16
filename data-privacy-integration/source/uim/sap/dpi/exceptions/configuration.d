module uim.sap.dpi.exceptions.configuration;

import uim.sap.dpi;

mixin(ShowModule!());

@safe:
class DPIConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(DPI) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(DPI) " ~ message, file, line, next);
  }
}
///
unittest {
  DPIConfigurationException ex1 = new DPIConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (DPI) Test message");

  DPIConfigurationException ex2 = new DPIConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (DPI) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}
