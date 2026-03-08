module uim.sap.bas.exceptions.validation;

import uim.sap.bas;

mixin(ShowModule!());

@safe:


class BASValidationException : BASException {
    this(string message) {
        super(message);
    }
}