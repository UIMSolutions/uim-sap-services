module uim.sap.sci.exceptions.authorization;

import uim.sap.sci;

class SCIAuthorizationException : SCIException {
    this(string msg = "Unauthorized", string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}
