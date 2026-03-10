module uim.sap.obs.exceptions.exception;

import uim.sap.obs;

mixin(ShowModule!());

@safe:

class OBSException : SAPException {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}
