module uim.sap.eventmesh.exceptions.configuration;

import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:

class EMConfigurationException : EMException {
  this(string message) {
    super("Configuration error: " ~ message);
  }
}
