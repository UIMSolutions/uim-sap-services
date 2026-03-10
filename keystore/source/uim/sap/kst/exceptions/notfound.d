module uim.sap.kst.exceptions.notfound;

import uim.sap.kst;

mixin(ShowModule!());

@safe:

class KSTNotFoundException : KSTException {
    this(string kind, string id) {
        super(kind ~ " not found: " ~ id);
    }
}
