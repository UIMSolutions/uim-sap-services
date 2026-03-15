module uim.sap.atm.exceptions.configuration;

import uim.sap.atm;

mixin(ShowModule!());

@safe:

class ATMConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(ADL) " ~ message);
  }
}
///
unittest {
  ATMConfigurationException ex = new ATMConfigurationException("Test message");
  assert(ex.message == "Configuration error: (ATM) Test message");
}
