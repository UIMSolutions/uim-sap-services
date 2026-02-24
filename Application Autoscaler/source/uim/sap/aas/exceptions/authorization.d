module uim.sap.aas.exceptions.authorization;

import uim.sap.aas;
@safe:

class AASAuthorizationException : AASException {
    this(string msg = "Unauthorized", string file = __FILE__, size_t line = __LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}
