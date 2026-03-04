module uim.sap.integrationsuite.exceptions.validation;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

class ISValidationException : ISException {
  this(string message) {
    super("Validation failed: " ~ message);
  }
}
