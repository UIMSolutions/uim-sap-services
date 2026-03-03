module uim.sap.featureflags.exceptions.validation;

import uim.sap.featureflags;

mixin(ShowModule!());

@safe:

class FFValidationException : FFException {
  this(string message) {
    super("Validation failed: " ~ message);
  }
}
