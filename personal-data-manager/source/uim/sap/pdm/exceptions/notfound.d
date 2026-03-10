module uim.sap.pdm.exceptions.notfound;

import uim.sap.pdm;

mixin(ShowModule!());

@safe:

class PDMNotFoundException : PDMException {
    this(string resource, string id, string file = __FILE__, size_t line = __LINE__) {
        super(resource ~ " not found: " ~ id, file, line);
    }
}
