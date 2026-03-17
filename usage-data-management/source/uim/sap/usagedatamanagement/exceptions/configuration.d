module uim.sap.usagedatamanagement.exceptions.configuration;

import uim.sap.usagedatamanagement;

mixin(ShowModule!());

@safe:

class UDMConfigurationException : SAPConfigurationException {
  this(string message) {
    super("(UDM) " ~ message);
  }
}
