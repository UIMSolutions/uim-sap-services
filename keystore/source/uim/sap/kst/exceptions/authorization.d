module uim.sap.kst.exceptions.authorization;

import uim.sap.kst;

mixin(ShowModule!());

@safe:

class KSTAuthorizationException : KSTException {
    this(string msg) {
        super(msg);
    }
}
