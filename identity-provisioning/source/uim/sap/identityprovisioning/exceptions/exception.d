module uim.sap.identityprovisioning.exceptions.exception;

import uim.sap.identityprovisioning;

mixin(ShowModule!());

@safe:

class IPException : SAPException {
  this(string message) {
    super(message);
  }
}
