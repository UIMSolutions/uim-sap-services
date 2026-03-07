module uim.sap.eventmesh.exceptions.validation;

import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:

class EVMValidationException : EVMException {
  this(string message) {
    super("Validation failed: " ~ message);
  }
}
