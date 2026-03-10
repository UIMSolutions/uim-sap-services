module uim.sap.cps.exceptions.validation;

import uim.sap.cps;

mixin(ShowModule!());

@safe:

class CPSValidationException : CPSException {
    this(string msg) { super(msg); }
}
