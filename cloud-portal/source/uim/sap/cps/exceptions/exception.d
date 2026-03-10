module uim.sap.cps.exceptions.exception;

import uim.sap.cps;

mixin(ShowModule!());

@safe:

class CPSException : SAPException {
  this(string msg) {
    super(msg);
  }
}
