module uim.sap.featureflags.exceptions.authorization;

import uim.sap.featureflags;

mixin(ShowModule!());

@safe:

class FFAuthorizationException : FFException {
  this(string message) {
    super("Unauthorized: " ~ message);
  }
}
