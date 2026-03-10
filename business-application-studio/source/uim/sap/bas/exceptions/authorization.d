module uim.sap.bas.exceptions.authorization;

import uim.sap.bas;

mixin(ShowModule!());

@safe:

class BASAuthorizationException : BASException {
  this(string message) {
    super(message);
  }
}
