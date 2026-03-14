module uim.sap.pre.exceptions.exception;

import uim.sap.pre;

mixin(ShowModule!());
@safe:
class PREException : SAPException {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}
