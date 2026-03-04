module uim.sap.integrationsuite.exceptions.authorization;

import uim.sap.integrationsuite;

mixin(ShowModule!());

@safe:

class ISAuthorizationException : ISException {
  this(string message) {
    super("Unauthorized: " ~ message);
  }
}
