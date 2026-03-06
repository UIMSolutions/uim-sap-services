module uim.sap.featureflags.exceptions.exception;

import uim.sap.featureflags;

mixin(ShowModule!());

@safe:

class FFLException : SAPException {
  this(string message) {
    super(message);
  }
}
