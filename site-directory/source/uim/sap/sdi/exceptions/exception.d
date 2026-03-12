module uim.sap.sdi.exceptions.exception;

import uim.sap.sdi;

mixin(ShowModule!());

@safe:

class SDIException : SAPException {
    this(string msg) { super(msg); }
}
