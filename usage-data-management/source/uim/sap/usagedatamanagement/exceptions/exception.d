module uim.sap.usagedatamanagement.exceptions.exception;

import uim.sap.usagedatamanagement;

mixin(ShowModule!());

@safe:

class UDMException : SAPException {
  this(string msg) {
    super(msg);
  }
}
