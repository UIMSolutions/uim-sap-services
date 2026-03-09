module uim.sap.mdi.exceptions.validation;

import uim.sap.mdi;

mixin(ShowModule!());

@safe:
class MDIValidationException : MDIException {
    this(string msg) { super(msg); }
}