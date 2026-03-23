module uim.sap.cag.exceptions.validation;

import uim.sap.cag;

mixin(ShowModule!());

@safe:

class CAGValidationException : CAGException {
    this(string message) {
        super(message);
    }
}