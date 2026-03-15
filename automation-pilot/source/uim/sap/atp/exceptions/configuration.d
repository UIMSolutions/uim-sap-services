module uim.sap.atp.exceptions.configuration;

import uim.sap.atp;

mixin(ShowModule!());

@safe:

class ATPConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(ATP) " ~ message);
  }
}
///
unittest {
  ATPConfigurationException ex = new ATPConfigurationException("Test message");
  assert(ex.message == "Configuration error: (ATP) Test message");
}