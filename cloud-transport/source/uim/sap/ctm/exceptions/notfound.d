module uim.sap.ctm.exceptions.notfound;

import uim.sap.ctm;

mixin(ShowModule!());

@safe:

class CTMNotFoundException : CTMException {
    this(string kind, string id) { super(kind ~ " not found: " ~ id); }
}
