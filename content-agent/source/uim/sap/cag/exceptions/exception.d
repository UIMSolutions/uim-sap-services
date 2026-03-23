module uim.sap.cag.exceptions.exception;

import uim.sap.cag;

mixin(ShowModule!());

@safe:

class CAGException : SAPException {
  this(string message) {
    super(message);
  }
}
