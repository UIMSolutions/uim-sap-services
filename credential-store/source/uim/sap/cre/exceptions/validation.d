module uim.sap.cre.exceptions.validation;

import uim.sap.cre;

mixin(ShowModule!());

@safe:

class CREValidationException : CREException {
    this(string msg) {
        super(msg);
    }
}
