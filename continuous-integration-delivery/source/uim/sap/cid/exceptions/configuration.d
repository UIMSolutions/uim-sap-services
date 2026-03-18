module uim.sap.cid.exceptions.configuration;
import uim.sap.cid;

mixin(ShowModule!());

@safe:

class CIDConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(CID) " ~ message);
  }

  this(string message, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
    super("(CID) " ~ message, file, line, next);
  }
}
///
unittest {
  CIDConfigurationException ex1 = new CIDConfigurationException("Test message");
  assert(ex1.message == "Configuration error: (CID) Test message");

  CIDConfigurationException ex2 = new CIDConfigurationException("Test message", "testfile.d", 123);
  assert(ex2.message == "Configuration error: (CID) Test message");
  assert(ex2.file == "testfile.d");
  assert(ex2.line == 123);
}