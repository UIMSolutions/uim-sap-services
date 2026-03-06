module uim.sap.eventmesh.exceptions.exception;

import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:

class EMException : SAPException {
  this(string message) {
    super(message);
  }
}
