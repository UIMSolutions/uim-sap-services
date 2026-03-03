module uim.sap.identityprovisioning.exceptions.configuration;

import uim.sap.identityprovisioning;

mixin(ShowModule!());

@safe:

class IPConfigurationException : IPException {
  this(string message) {
    super("Configuration error: " ~ message);
  }
}
