module uim.sap.bas.exceptions.validation;

import uim.sap.bas;

module(ShowModule!());

@safe:

class BASValidationException : BASException {
    this(string message) {
        super(message);
    }
}