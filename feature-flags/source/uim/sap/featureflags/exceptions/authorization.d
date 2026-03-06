module uim.sap.featureflags.exceptions.authorization;

import uim.sap.featureflags;

mixin(ShowModule!());

@safe:

class FFLAuthorizationException : FFLException {
  this(string message) {
    super("Unauthorized: " ~ message);
  }
}
