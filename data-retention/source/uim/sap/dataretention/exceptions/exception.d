module uim.sap.dataretention.exceptions.exception;

import uim.sap.dataretention;

mixin(ShowModule!());

@safe:

class DRMException : SAPException {
  this(string msg) {
    super(msg);
  }
}
