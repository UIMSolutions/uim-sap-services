module uim.sap.mon.exceptions.exception;

import uim.sap.mon;

mixin(ShowModule!());

@safe:

class MONException : SAPException {
  this(string msg) {
    super(msg);
  }
}
