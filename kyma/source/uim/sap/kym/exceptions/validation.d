module uim.sap.kym.exceptions.validation;

import uim.sap.kym;

mixin(ShowModule!());

@safe:

class KYMValidationException : KYMException {
    this(string msg) {
        super(msg);
    }
}
