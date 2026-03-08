module uim.sap.bas.exceptions.exception;

import uim.sap.bas;

mixin(ShowModule!());

@safe:


class BASException : SAPException {
    this(string message) {
        super(message);
    }
}