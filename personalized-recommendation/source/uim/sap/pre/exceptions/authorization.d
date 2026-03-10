module uim.sap.pre.exceptions.authorization;

import uim.sap.pre;

mixin(ShowModule!());

class PREAuthorizationException : PREException {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super(msg, file, line);
    }
}
