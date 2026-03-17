module uim.sap.dataretention.exceptions.validation;

import uim.sap.dataretention;

mixin(ShowModule!());

@safe:

class DRMValidationException : DRMException {
  this(string msg) {
    super(msg);
  }
}
