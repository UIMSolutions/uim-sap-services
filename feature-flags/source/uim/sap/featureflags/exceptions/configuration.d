module uim.sap.featureflags.exceptions.configuration;

import uim.sap.featureflags;

mixin(ShowModule!());

@safe:

class FFConfigurationException : FFException {
  this(string message) {
    super("Configuration error: " ~ message);
  }
}
