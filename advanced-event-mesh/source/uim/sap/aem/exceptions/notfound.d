module uim.sap.aem.exceptions.notfound;

import uim.sap.aem;

mixin(ShowModule!());

@safe:

class AEMNotFoundException : AEMException {
    this(string resource, string identifier) {
        super(resource ~ " not found: " ~ identifier);
    }
}


