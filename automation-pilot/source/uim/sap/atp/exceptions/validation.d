module uim.sap.atp.exceptions.validation;

import uim.sap.atp;

mixin(ShowModule!());

@safe:

class ATPValidationException : ATPException {
  this(string msg) {
    super(msg);
  }
}
