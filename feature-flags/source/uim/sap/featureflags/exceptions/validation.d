module uim.sap.featureflags.exceptions.validation;

import uim.sap.featureflags;

mixin(ShowModule!());

@safe:

class FFLValidationException : FFLException {
  this(string message) {
    super("Validation failed: " ~ message);
  }
}
