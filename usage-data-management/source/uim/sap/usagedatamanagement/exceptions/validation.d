module uim.sap.usagedatamanagement.exceptions.validation;

import uim.sap.usagedatamanagement;

mixin(ShowModule!());

@safe:

class UDMValidationException : UDMException {
  this(string msg) {
    super(msg);
  }
}
