module uim.sap.kst.exceptions.exception;

import uim.sap.kst;

mixin(ShowModule!());

@safe:

class KSTException : SAPException {
    this(string msg) {
        super(msg);
    }
}
