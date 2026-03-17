module uim.sap.dataretention.exceptions.configuration;

import uim.sap.dataretention;

mixin(ShowModule!());

@safe:

class DRMConfigurationException : SAPConfigurationException {
  this(string msg) {
    super("(DRM) " ~ msg);
  }
}
