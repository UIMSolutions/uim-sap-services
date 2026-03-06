module uim.sap.identityprovisioning.exceptions.authorization;

import uim.sap.identityprovisioning;

mixin(ShowModule!());

@safe:

class IPVAuthorizationException : IPVException {
  this(string message) {
    super("Unauthorized: " ~ message);
  }
}
