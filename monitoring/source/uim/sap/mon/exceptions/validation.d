module uim.sap.mon.exceptions.validation;

import uim.sap.mon;

mixin(ShowModule!());

@safe:

class MONValidationException : MONException {
    this(string msg) {
        super(msg);
    }
}