module uim.sap.identityprovisioning.exceptions.configuration;

import uim.sap.identityprovisioning;

mixin(ShowModule!());

@safe:

class IPVConfigurationException : IPVException {
  this(string message) {
    super("Configuration error: " ~ message);
  }
}
