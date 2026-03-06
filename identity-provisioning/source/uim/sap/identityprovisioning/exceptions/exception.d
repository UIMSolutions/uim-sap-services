module uim.sap.identityprovisioning.exceptions.exception;

import uim.sap.identityprovisioning;

mixin(ShowModule!());

@safe:

class IPVException : SAPException {
  this(string message) {
    super(message);
  }
}
