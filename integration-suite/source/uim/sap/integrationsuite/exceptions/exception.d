module uim.sap.integrationsuite.exceptions.exception;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

class ISException : SAPException {
  this(string message) {
    super(message);
  }
}
