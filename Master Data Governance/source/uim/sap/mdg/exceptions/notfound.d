module uim.sap.mdg.exceptions.notfound;

import uim.sap.mdg;
@safe:

class MDGNotFoundException : MDGException {
    this(string kind, string id) {
        super(kind ~ " not found: " ~ id);
    }
}
