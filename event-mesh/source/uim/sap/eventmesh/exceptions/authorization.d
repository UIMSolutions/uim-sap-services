module uim.sap.eventmesh.exceptions.authorization;

import uim.sap.eventmesh;

mixin(ShowModule!());

@safe:

class EVMAuthorizationException : EVMException {
  this(string message) {
    super("Unauthorized: " ~ message);
  }
}
