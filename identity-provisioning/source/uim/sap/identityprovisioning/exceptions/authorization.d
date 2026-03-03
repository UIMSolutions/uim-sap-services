module uim.sap.identityprovisioning.exceptions.authorization;

import uim.sap.identityprovisioning;

mixin(ShowModule!());

@safe:

class IPAuthorizationException : IPException {
  this(string message) {
    super("Unauthorized: " ~ message);
  }
}
