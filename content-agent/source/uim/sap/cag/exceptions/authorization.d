module uim.sap.cag.exceptions.authorization;

import uim.sap.cag;

mixin(ShowModule!());

@safe:

class CAGAuthorizationException : CAGException {
  this(string message) {
    super(message);
  }
}
