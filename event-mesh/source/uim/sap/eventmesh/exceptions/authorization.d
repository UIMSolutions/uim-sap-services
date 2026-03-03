module uim.sap.eventmesh.exceptions.authorization;

import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:

class EMAuthorizationException : EMException {
  this(string message) {
    super("Unauthorized: " ~ message);
  }
}
