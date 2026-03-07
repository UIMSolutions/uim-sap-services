module uim.sap.atm.exceptions.exception;

import uim.sap.atm;

mixin(ShowModule!());

@safe:

class ATMException : SAPException {
    this(string message) {
        super(message);
    }
}
