module uim.sap.cre.exceptions.notfound;

import uim.sap.cre;

mixin(ShowModule!());

@safe:

class CRENotFoundException : CREException {
    this(string kind, string id) {
        super(kind ~ " not found: " ~ id);
    }
}
