module uim.sap.sdi.exceptions.validation;

import uim.sap.sdi;

mixin(ShowModule!());

@safe:

class SDIValidationException : SDIException {
    this(string msg) { super(msg); }
}
