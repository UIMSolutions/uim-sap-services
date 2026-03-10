module uim.sap.pre.exceptions.notfound;

import uim.sap.pre;

mixin(ShowModule!());

class PRENotFoundException : PREException {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}
