module uim.sap.aem.exceptions.authorization;

import uim.sap.aem;

mixin(ShowModule!());

@safe:

class AEMAuthorizationException : AEMException {
  this(string message) {
    super("Unauthorized: " ~ message);
  }
}
