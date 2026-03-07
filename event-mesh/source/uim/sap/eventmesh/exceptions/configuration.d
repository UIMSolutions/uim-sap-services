module uim.sap.eventmesh.exceptions.configuration;

import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:

class EVMConfigurationException : EVMException {
  this(string message) {
    super("Configuration error: " ~ message);
  }
}
