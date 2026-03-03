module uim.sap.eventmesh.exceptions.validation;

import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:

class EMValidationException : EMException {
  this(string message) {
    super("Validation failed: " ~ message);
  }
}
