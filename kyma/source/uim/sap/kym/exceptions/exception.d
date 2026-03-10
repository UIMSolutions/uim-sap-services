module uim.sap.kym.exceptions.exception;

import uim.sap.kym;

mixin(ShowModule!());

@safe:

class KYMException : SAPException {
    this(string msg) {
        super(msg);
    }
}
