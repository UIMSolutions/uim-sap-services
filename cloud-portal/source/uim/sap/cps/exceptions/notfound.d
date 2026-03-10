module uim.sap.cps.exceptions.notfound;

import uim.sap.cps;

mixin(ShowModule!());

@safe:

class CPSNotFoundException : CPSException {
    this(string kind, string id) { super(kind ~ " not found: " ~ id); }
}
