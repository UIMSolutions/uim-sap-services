module uim.sap.prm.exceptions.exception;

import uim.sap.prm;

mixin(ShowModule!());

@safe:

class PRMException : SAPException {
  this(string msg) {
    super(msg);
  }
}
