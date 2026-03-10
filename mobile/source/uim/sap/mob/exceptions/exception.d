module uim.sap.mob.exceptions.exception;

import uim.sap.mob;

mixin(ShowModule!());

@safe:

class MOBException : SAPException {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}
