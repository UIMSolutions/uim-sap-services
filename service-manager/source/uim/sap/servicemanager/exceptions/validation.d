module uim.sap.servicemanager.exceptions.validation;

import uim.sap.servicemanager;

mixin(ShowModule!());

@safe:

class SVMValidationException : SVMException {
  this(string msg) {
    super(msg);
  }
}
