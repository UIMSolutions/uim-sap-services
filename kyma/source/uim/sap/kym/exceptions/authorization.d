module uim.sap.kym.exceptions.authorization;

import uim.sap.kym;

mixin(ShowModule!());

@safe:

class KYMAuthorizationException : KYMException {
    this(string msg) {
        super(msg);
    }
}
