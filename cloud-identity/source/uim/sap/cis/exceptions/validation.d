module uim.sap.cis.exceptions.validation;

import uim.sap.cis;

mixin(ShowModule!());

@safe:

class CISValidationException : CISException {
    this(string msg) {
        super(msg);
    }
}