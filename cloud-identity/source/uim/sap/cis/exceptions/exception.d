module uim.sap.cis.exceptions.exception;

import uim.sap.cis;

mixin(ShowModule!());

@safe:

class CISException : Exception {
    this(string msg) {
        super(msg);
    }
}