module uim.sap.integrationsuite.exceptions.configuration;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

class ISConfigurationException : ISException {
  this(string message) {
    super("Configuration error: " ~ message);
  }
}
