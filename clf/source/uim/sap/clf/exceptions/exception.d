module uim.sap.clf.exceptions.exception;

import uim.sap.clf;

mixin(Show)
class CLFException : Exception {
    this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}