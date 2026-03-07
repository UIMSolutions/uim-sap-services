module uim.sap.atm.exceptions.validation;

import uim.sap.atm;

mixin(ShowModule!());

@safe:

class ATMValidationException : ATMException {
    this(string message) {
        super("Validation failed: " ~ message);
    }
}