module uim.sap.mob.exceptions.validation;

import uim.sap.mob;

mixin(ShowModule!());

@safe:

class MOBValidationException : MOBException {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super("Validation failed: " ~ msg, file, line);
    }
}
