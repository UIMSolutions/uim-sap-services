module uim.sap.bas.exceptions.configuration;

import uim.sap.bas;

mixin(ShowModule!());

@safe:


class BASConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(ADL) " ~ message);
  }
}
///
unittest {
  BASConfigurationException ex = new BASConfigurationException("Test message");
  assert(ex.message == "Configuration error: (BAS) Test message");
}