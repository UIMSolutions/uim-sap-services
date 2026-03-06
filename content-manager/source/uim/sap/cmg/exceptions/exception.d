module uim.sap.cmg.exceptions.exception;

import uim.sap.cmg;

mixin(ShowModule!());

@safe:

class CMGException : SAPException {
    this(string msg) { super(msg); }
}