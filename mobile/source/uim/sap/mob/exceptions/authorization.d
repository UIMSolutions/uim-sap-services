module uim.sap.mob.exceptions.authorization;

import uim.sap.mob;

mixin(ShowModule!());

@safe:

class MOBAuthorizationException : MOBException {
    this(string msg, string file = __FILE__, size_t line = __LINE__) {
        super("Authorization failed: " ~ msg, file, line);
    }
}
