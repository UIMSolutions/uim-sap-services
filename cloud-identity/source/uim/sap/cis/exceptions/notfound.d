module uim.sap.cis.exceptions.notfound;

import uim.sap.cis;

mixin(ShowModule!());

@safe:

class CISNotFoundException : CISException {
    this(string kind, string id) {
        super(kind ~ " not found: " ~ id);
    }
}
