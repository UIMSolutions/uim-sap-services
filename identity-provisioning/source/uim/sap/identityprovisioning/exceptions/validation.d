module uim.sap.identityprovisioning.exceptions.validation;

import uim.sap.identityprovisioning;

mixin(ShowModule!());

@safe:

class IPValidationException : IPException {
  this(string message) {
    super("Validation failed: " ~ message);
  }
}
