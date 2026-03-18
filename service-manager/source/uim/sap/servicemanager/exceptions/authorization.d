module uim.sap.servicemanager.exceptions.authorization;

import uim.sap.servicemanager;

mixin(ShowModule!());

@safe:

class SVMAuthorizationException : SVMException {
  this(string msg) {
    super(msg);
  }
}
