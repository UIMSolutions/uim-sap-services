module uim.sap.atm.exceptions.notfound;

import uim.sap.atm;

mixin(ShowModule!());

@safe:

class ATMNotFoundException : ATMException {
    this(string resource, string identifier) {
        super(resource ~ " not found: " ~ identifier);
    }
}


