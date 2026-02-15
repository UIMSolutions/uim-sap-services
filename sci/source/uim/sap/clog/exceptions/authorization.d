module uim.sap.clog.exceptions.authorization;

import uim.sap.clog;

class SCIAuthorizationException : SCIException {
    this(string msg = "Unauthorized", string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}
