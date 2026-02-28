module uim.sap.aem.exceptions.validation;

import uim.sap.aem;

mixin(ShowModule!());

@safe:

class AEMValidationException : AEMException {
  this(string message) {
    super("Validation failed: " ~ message);
  }
}
