module uim.sap.atp.exceptions.configuration;

import uim.sap.atp;

mixin(ShowModule!());

@safe:

class ATPConfigurationException : ATPException {
  this(string msg) {
    super(msg);
  }
}
