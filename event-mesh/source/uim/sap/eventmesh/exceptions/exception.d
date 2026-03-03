module uim.sap.eventmesh.exceptions.exception;

import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:

class EMException : Exception {
  this(string message) {
    super(message);
  }
}
