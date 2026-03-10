module uim.sap.kst.exceptions.validation;

import uim.sap.kst;

mixin(ShowModule!());

@safe:

class KSTValidationException : KSTException {
    this(string msg) {
        super(msg);
    }
}
