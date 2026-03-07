module uim.sap.eventmesh.exceptions.exception;

import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:

class EVMException : SAPException {
  this(string message) {
    super(message);
  }
}
