module uim.sap.clg.exceptions.logvalidation;

import uim.sap.clg;

mixin(ShowModule!());

@safe:

class CLGLogValidationException : CLGException {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}