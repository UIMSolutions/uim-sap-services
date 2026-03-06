module uim.sap.cre.exceptions.exception;

import uim.sap.cre;

mixin(ShowModule!());

@safe:

class CREException : SAPException {
    this(string msg) {
        super(msg);
    }
}