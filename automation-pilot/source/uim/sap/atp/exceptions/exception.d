module uim.sap.atp.exceptions.exception;

import uim.sap.atp;

mixin(ShowModule!());

@safe:

class ATPException : SAPException {
  this(string msg) {
    super(msg);
  }
}
