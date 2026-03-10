module uim.sap.pdm.exceptions.exception;

import uim.sap.pdm;

mixin(ShowModule!());

@safe:

class PDMException : SAPException {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}
