module uim.sap.pdm.exceptions.authorization;

import uim.sap.pdm;

mixin(ShowModule!());

@safe:

class PDMAuthorizationException : PDMException {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super("Authorization failed: " ~ msg, file, line);
    }
}
