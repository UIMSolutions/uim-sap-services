module uim.sap.dataretention.exceptions.authorization;

import uim.sap.dataretention;

mixin(ShowModule!());

@safe:

class DRMAuthorizationException : DRMException {
  this(string msg) {
    super(msg);
  }
}
