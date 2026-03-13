module uim.sap.prm.exceptions.configuration;

import uim.sap.prm;

mixin(ShowModule!());

@safe:

class PRMConfigurationException : PRMException {
  this(string msg) {
    super(msg);
  }
}
