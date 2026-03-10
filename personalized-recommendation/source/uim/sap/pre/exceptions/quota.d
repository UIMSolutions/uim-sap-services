module uim.sap.pre.exceptions.quota;

import uim.sap.pre;

mixin(ShowModule!());

class PREQuotaExceededException : PREException {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}
