module uim.sap.mdi.exceptions.notfound;

import uim.sap.mdi;

mixin(ShowModule!());

@safe:
class MDINotFoundException : MDIException {
    this(string kind, string id) { super(kind ~ " not found: " ~ id); }
}
