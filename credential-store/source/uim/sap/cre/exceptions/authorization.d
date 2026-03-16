module uim.sap.cre.exceptions.authorization;

import uim.sap.cre;

mixin(ShowModule!());

@safe:
class CREAuthorizationException : CREException {
  this(string msg) {
    super(msg);
  }
}
