module uim.sap.pre.exceptions.validation;

import uim.sap.pre;

mixin(ShowModule!());

class PREValidationException : PREException {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}
