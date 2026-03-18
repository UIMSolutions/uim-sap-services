module uim.sap.servicemanager.exceptions.exception;

import uim.sap.servicemanager;

mixin(ShowModule!());

@safe:

class SVMException : SAPException {
  this(string msg) {
    super(msg);
  }
}
