module uim.sap.usagedatamanagement.exceptions.authorization;

import uim.sap.usagedatamanagement;

mixin(ShowModule!());

@safe:

class UDMAuthorizationException : UDMException {
  this(string msg) {
    super(msg);
  }
}
