module uim.sap.prm.exceptions.authorization;

import uim.sap.prm;

mixin(ShowModule!());

@safe:

class PRMAuthorizationException : PRMException {
  this(string msg) {
    super(msg);
  }
}
