module uim.sap.obs.exceptions.authorization;

import uim.sap.obs;

mixin(ShowModule!());

@safe:

class OBSAuthorizationException : OBSException {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super("Authorization failed: " ~ msg, file, line);
    }
}
