module uim.sap.ctm.exceptions.validation;

import uim.sap.ctm;

mixin(ShowModule!());

@safe:

class CTMValidationException : CTMException {
    this(string msg) { super(msg); }
}
