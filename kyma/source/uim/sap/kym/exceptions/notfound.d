module uim.sap.kym.exceptions.notfound;

import uim.sap.kym;

mixin(ShowModule!());

@safe:

class KYMNotFoundException : KYMException {
    this(string kind, string id) {
        super(kind ~ " not found: " ~ id);
    }
}
