module uim.sap.servicemanager.exceptions.configuration;

import uim.sap.servicemanager;

mixin(ShowModule!());

@safe:

class SVMConfigurationException : SAPConfigurationException {
  this(string msg) {
    super("(SVM) " ~ msg);
  }
}
