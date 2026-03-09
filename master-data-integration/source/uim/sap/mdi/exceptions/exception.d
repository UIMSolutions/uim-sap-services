module uim.sap.mdi.exceptions.exception;

import uim.sap.mdi;

mixin(ShowModule!());

@safe:
class MDIException : SAPException {
    this(string msg) { super(msg); }
}
