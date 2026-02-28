module uim.sap.cmg.exceptions.validation;

import uim.sap.cmg;

mixin(ShowModule!());

@safe:

class CMGValidationException : CMGException {
    this(string msg) { super(msg); }
}
