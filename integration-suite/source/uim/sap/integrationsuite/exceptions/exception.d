module uim.sap.integrationsuite.exceptions.exception;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

class ISException : Exception {
  this(string message) {
    super(message);
  }
}
