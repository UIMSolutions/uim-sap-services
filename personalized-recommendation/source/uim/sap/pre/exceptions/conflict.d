module uim.sap.pre.exceptions.conflict;

import uim.sap.pre;

mixin(ShowModule!());

class PREConflictException : PREException {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}
