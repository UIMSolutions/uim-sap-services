module uim.sap.prm.exceptions.validation;

import uim.sap.prm;

mixin(ShowModule!());

@safe:

class PRMValidationException : PRMException {
  this(string msg) {
    super(msg);
  }
}
