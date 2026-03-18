module uim.sap.ctm.exceptions.exception;

import uim.sap.ctm;

mixin(ShowModule!());

@safe:

class CTMException : SAPException {
    this(string msg) {
        super(msg);
    }
}
