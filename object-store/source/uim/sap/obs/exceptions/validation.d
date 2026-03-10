module uim.sap.obs.exceptions.validation;

import uim.sap.obs;

mixin(ShowModule!());

@safe:

class OBSValidationException : OBSException {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super("Validation failed: " ~ msg, file, line);
    }
}
