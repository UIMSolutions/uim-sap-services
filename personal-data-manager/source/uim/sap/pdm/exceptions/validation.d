module uim.sap.pdm.exceptions.validation;

import uim.sap.pdm;

mixin(ShowModule!());

@safe:

class PDMValidationException : PDMException {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super("Validation failed: " ~ msg, file, line);
    }
}
