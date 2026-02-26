module uim.sap.atp.exceptions.authorization;

import uim.sap.atp;

mixin(ShowModule!());

@safe:

class ATPAuthorizationException : ATPException {
  this(string msg) {
    super(msg);
  }
}
