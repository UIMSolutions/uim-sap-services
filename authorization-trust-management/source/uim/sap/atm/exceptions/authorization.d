module uim.sap.atm.exceptions.authorization;

import uim.sap.atm;

mixin(ShowModule!());

@safe:

class ATMAuthorizationException : ATMException {
    this(string message) {
        super("Unauthorized: " ~ message);
    }
}
